//
//  ChatServices.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine


final class ChatServices{
    
    private init(){}
    
    static let shared = ChatServices()
    
    private let chatsCollections = Firestore.firestore().collection("chats")
    
    func getChatDocument(for id: String) -> DocumentReference{
        chatsCollections.document(id)
    }
    
    func createChat(for participantIds: [String]) async throws{
        let chat = Chat(id: UUID().uuidString, participants: participantIds)
        try chatsCollections.document(chat.id).setData(from: chat, merge: false)
    }
    
    func updateLastChatMessage(for id: String, shortMessage: ShortMessage) async throws{
        
        let data = try Firestore.Encoder().encode(shortMessage)
        
        let dict: [String: Any] = [
            Chat.CodingKeys.lastMessage.rawValue: data
        ]
        try await getChatDocument(for: id).updateData(dict)
    }
    
    func deleteChat(for id: String) async throws{
        try await getChatDocument(for: id).delete()
    }
    
    func chatQuery(userId: String, limit: Int? = nil) -> Query{
        chatsCollections
            .limitOptionally(to: limit)
            .whereField(Chat.CodingKeys.participants.rawValue, arrayContains: userId)
            .order(by: Chat.CodingKeys.createdAt.rawValue)
    }
    
    func getUserChats(userId: String) async throws -> [Chat]{
        try await chatQuery(userId: userId)
            .getDocuments(as: Chat.self)
    }
    
    func addChatListener(userId: String) ->(AnyPublisher<([Chat], [DocumentChangeType]), Error>, ListenerRegistration){
        chatQuery(userId: userId, limit: 1)
            .addSnapshotListenerWithChangeType(as: Chat.self)
    }
}
