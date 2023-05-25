//
//  ChatViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 25.05.2023.
//

import Foundation


class ChatViewModel: ObservableObject{
    
    @Published private(set) var conversations = [Conversation]()
    private let chatService = ChatServices.shared
    private let userService = UserService.share
    private var listener = FBListener()
    private let cancelBag = CancelBag()
    
    
    init(){
        
    }
    
    
    func fetchChats(){
        guard let currentUserId = userService.getFBUserId() else {return}
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
        guard let currentUserId = userService.getFBUserId() else {return}
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
            } receiveValue: { (chat, changedType) in
                
                guard let chat = chat.first, let type = changedType.last else {
                    //remove
                    return
                }
                
                switch type{
                    
                case .added:
                    print("added")
                case .modified:
                    print("modified")
                case .removed:
                    print("removed")
                }
         
//                if self.conversations.contains(where: {$0.id == chat.id}){
//
//                }else{
//                    self.addNewConversations(chat: chat)
//                }
            }
            .store(in: cancelBag)
    }
    
    private func addNewConversations(chat: Chat){
        guard let currentUserId = userService.getFBUserId() else {return}
        if conversations.contains(where: {$0.id == chat.id}){
            Task{
                let newConversation = try await createConversations(for: currentUserId, chats: [chat])
                await MainActor.run{
                    self.conversations = newConversation
                }
            }
        }
    }
}
