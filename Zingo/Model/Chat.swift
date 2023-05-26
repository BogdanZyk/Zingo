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

extension Conversation{
    static let mock: Conversation = .init(chat: .mock, conversationUser: .init(user: .mock))
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


extension Chat{
    static let mock: Chat = .init(id: UUID().uuidString, lastMessage: .init(message: .mocks.first!), participants: ["1", "2"])
}



