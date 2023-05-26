//
//  ChatViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 25.05.2023.
//

import Foundation


class ChatViewModel: ObservableObject{
    
    @Published private(set) var conversations = [Conversation]()
    @Published private(set) var currentUserId: String?
    private let chatService = ChatServices.shared
    private let userService = UserService.share
    private var listener = FBListener()
    private let cancelBag = CancelBag()
    
    
    init(){
        currentUserId = userService.getFBUserId()
        fetchChats()
        startChatsListener()
    }
    
    deinit{
        listener.cancel()
        cancelBag.cancel()
    }
    
    func fetchChats(){
        guard let currentUserId else {return}
        Task(priority: .userInitiated){
            do{
                let chats = try await chatService.getUserChats(userId: currentUserId)
                let conversations = try await createConversations(for: currentUserId, chats: chats)
                
                await MainActor.run {
                    self.conversations = conversations
                }
                
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    
    func createConversations(for userId: String, chats: [Chat]) async throws -> [Conversation]{
        
        let usersIds = chats.compactMap({$0.participants.first(where: {$0 != userId})})
        let users = try await userService.getUsers(ids: usersIds).map({ShortUser(user: $0)})
        var conversations = [Conversation]()
        chats.forEach { chat in
            guard let user = users.first(where: {chat.participants.contains($0.id)}) else{
                return
            }
            conversations.append(.init(chat: chat, conversationUser: user))
        }
        return conversations
    }
    
    func startChatsListener(){
        guard let currentUserId else {return}
        let (pub, listener) = chatService.addChatListener(userId: currentUserId)
        
        
        self.listener.listener = listener
        
        pub
            .sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] (chat, changedType) in
                            
                guard let self = self else { return }
                
                chat.forEach { chat in
                    self.modifiedChat(chat)
                }
            }
            .store(in: cancelBag)
    }
    
    @MainActor
    func removeChat(_ id: String) async{
        do{
            conversations.removeAll(where: {$0.id == id})
            try await chatService.deleteChat(for: id)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    private func addNewConversationsIfNeeded(_ chat: Chat){
        guard let currentUserId else {return}
        if conversations.contains(where: {$0.id == chat.id}){
            Task{
                let newConversation = try await createConversations(for: currentUserId, chats: [chat])
                await MainActor.run{
                    self.conversations = newConversation
                }
            }
        }
    }
    
    private func modifiedChat(_ chat: Chat){
        guard let index = conversations.firstIndex(where: {$0.id == chat.id}) else {return}
        conversations[index].chat = chat
    }
    
}
