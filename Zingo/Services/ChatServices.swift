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
    
    @discardableResult
    func createChat(for participantIds: [String]) async throws -> Chat{
        let chat = Chat(id: UUID().uuidString, participants: participantIds)
        try chatsCollections.document(chat.id).setData(from: chat, merge: true)
        return chat
    }
    
    func updateLastChatMessage(for id: String, shortMessage: ShortMessage) async throws{
        
        let data = try Firestore.Encoder().encode(shortMessage)
        
        let dict: [String: Any] = [
            Chat.CodingKeys.lastMessage.rawValue: data
        ]
        try await getChatDocument(for: id).updateData(dict)
    }
    
    func viewLastChatMessage(for id: String)  async throws{
        let dict: [String: Any] = [
           "lastMessage.view" : true
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
    
    func getChat(participantId: String, currentUserId: String) async throws -> Chat?{
        return try await chatsCollections
            .whereField(Chat.CodingKeys.participants.rawValue, arrayContains: participantId)
            .getDocuments(as: Chat.self)
            .first(where: {$0.participants.contains(currentUserId)})
    }
    
    func addChatListener(userId: String) ->(AnyPublisher<([Chat], [DocumentChangeType]), Error>, ListenerRegistration){
        chatQuery(userId: userId, limit: nil)
            .addSnapshotListenerWithChangeType(as: Chat.self)
    }
}
