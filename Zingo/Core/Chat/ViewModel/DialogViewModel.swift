//
//  DialogViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 25.05.2023.
//

import Foundation
import SwiftUI

class DialogViewModel: ObservableObject{
    
    @Published var text: String? = ""
    
    @Published private(set) var messages = [Message]()
    @Published private(set) var participant: ShortUser?
    @Published var currentUserId: String?
    @Published private var chatId: String?
    @Published var error: Error?
    var lastMessageId: String?
    
    private let userService = UserService.share
    private let chatService = ChatServices.shared
    private let messageService = MessageService.shared
    private var lastDoc = FBLastDoc()
    private var fbListener = FBListener()
    private var totalCountMessage: Int = 0
    
    private var cancelBag = CancelBag()

    init(participant: ShortUser, chatId: String){
        currentUserId = userService.getFBUserId()
        self.participant = participant
        self.chatId = chatId
        fetchTotalCountMessage(chatId)
        startMessageListener(chatId)
        fetchMessages(chatId)
    }
    
    init(participantId: String){
        currentUserId = userService.getFBUserId()
        fetchParticipant(for: participantId)
        startChatSubs()
    }
    
    func createChatIfNeeded() async throws -> String{
        guard let participantId = participant?.id, let currentUserId else {
            throw AppError.custom(errorDescription: "Error create chat")
        }
        if let chat = try? await chatService.getChat(participantId: participantId, currentUserId: currentUserId){
            return chat.id
        }else{
            return try await chatService.createChat(for: [participantId, currentUserId]).id
        }
    }
    
    @MainActor
    func sendMessage() async{
        if let chatId, !messages.isEmpty{
            await sendMessage(chatId)
        }else if let newChat = try? await createChatIfNeeded(){
            self.chatId = newChat
            await sendMessage(newChat)
        }
    }
}

extension DialogViewModel{
    private func shouldNextPageLoader(_ messageId: String) -> Bool{
        (messages.last?.id == messageId) && totalCountMessage > messages.count
    }
    
    func loadNextPage(_ messageId: String){
        guard let chatId else { return }
        if shouldNextPageLoader(messageId){
            withAnimation {
                fetchMessages(chatId)
            }
        }
    }
}


// Listener
extension DialogViewModel{
    
    func startMessageListener(_ chatId: String){
        let (publisher, listener) = messageService.addListenerForMessages(chatId: chatId)
            
        fbListener.listener = listener
        
        publisher.sink { completion in
            switch completion{
                
            case .finished: break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: {[weak self] (messages, changed) in
            guard let self = self,
                  let message = messages.last,
                  let changedType = changed.last  else {return}
            
            switch changedType{
            case .added:
                self.addNewMessage(message)
            case .modified:
                self.modifiedMessage(message)
                
            default: break
            }
        }
        .store(in: cancelBag)
    }
    
    
    private func addNewMessage(_ message: Message){
        if !self.messages.contains(where: {$0.id == message.id}){
            self.messages.insert(message, at: 0)
            self.totalCountMessage += 1
            self.lastMessageId = message.id
        }
    }
    
    private func modifiedMessage(_ message: Message){
        guard let index = messages.firstIndex(where: {$0.id == message.id}),
              (messages.count - 1) >= index else {return}
        self.messages[index] = message
    }
}

extension DialogViewModel{
    
    func fetchMessages(_ chatId: String){
        Task{
            let (messages, lastDoc) = try await messageService.fetchPaginatedMessage(for: chatId, lastDocument: lastDoc.lastDocument)
            await MainActor.run {
                self.lastDoc.lastDocument = lastDoc
                self.messages.append(contentsOf: messages)
            }
        }
    }
    
    private func fetchTotalCountMessage(_ chatId: String){
        Task{
            let total = try await messageService.getCountAllMessages(chatId: chatId)
            await MainActor.run {
                print("total message", total)
                self.totalCountMessage = total
            }
        }
    }
    
    private func getChatId(participantId: String) async -> String?{
        guard let currentUserId else { return nil }
        return try? await chatService.getChat(participantId: participantId, currentUserId: currentUserId)?.id
    }
    
    func viewMessage(_ message: Message){
        guard let chatId, let currentUserId, message.senderId != currentUserId else { return }
        Task{
            if !(message.viewed ?? false){
                print("view messaeg", message.text)
                try await messageService.viewMessage(chatId: chatId, messageId:message.id)
            }
        }
    }
}

extension DialogViewModel{
    
    @MainActor
    private func sendMessage(_ chatId: String) async{
        guard let participantId = participant?.id, let currentUserId, let text else {
            return}
        do{
            let message = Message(id: UUID().uuidString, chatId: chatId, text: text, senderId: currentUserId, recipientId: participantId)
            self.text = ""
            try await messageService.sendMessage(for: chatId, message)
        }catch{
            self.error = error
        }
    }
    
    private func fetchParticipant(for id: String){
        Task{
            do{
                let user = try await userService.getUser(for: id)
                let chatId = await getChatId(participantId: user.id)
                await MainActor.run {
                    self.participant = .init(user: user)
                    self.chatId = chatId
                }
            }catch{
                self.error = error
            }
        }
    }
    
    private func startChatSubs(){
        $chatId
            .dropFirst()
            .sink {[weak self] chatId in
                guard let self = self, let chatId else {return}
                fetchTotalCountMessage(chatId)
                fetchMessages(chatId)
                startMessageListener(chatId)
            }
            .store(in: cancelBag)
    }
}
