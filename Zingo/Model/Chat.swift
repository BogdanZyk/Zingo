//
//  Chat.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI


struct Conversation: Identifiable{
    
    var id: String{ chat.id }
    var chat: Chat
    let conversationUser: ShortUser
    
}

extension Conversation: Hashable{
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }
}

extension Conversation{
    static let mocks: [Conversation] = [.init(chat: .mocks.first!, conversationUser: .init(user: .mock)),
                                        .init(chat: .mocks.last!, conversationUser: .init(user: .mock))]
}

struct Chat: Identifiable, Codable{
    let id: String
    var lastMessage: ShortMessage?
    var participants: [String]
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case lastMessage
        case participants
        case createdAt
    }
}

extension Chat: Hashable{
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }
}

extension Chat{
    
    static let mocks: [Chat] = [
        .init(id: UUID().uuidString, lastMessage: .init(message: .mocks.first!), participants: ["1", "2"]),
        .init(id: UUID().uuidString, lastMessage: .init(message: .mocks.first!), participants: ["1", "2"])
    ]
      
}



