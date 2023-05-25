//
//  Chat.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI


struct Conversation: Identifiable{
    var id: String{ chat.id }
    let chat: Chat
    let conversationUser: ShortUser
}

extension Conversation{
    static let mock: Conversation = .init(chat: .mock, conversationUser: .init(user: .mock))
}

struct Chat: Identifiable, Codable{
    let id: String
    var lastMessage: ShortMessage?
    var unreadCount: Int = 0
    var participants: [String]
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case lastMessage
        case unreadCount
        case participants
        case createdAt
    }
}


extension Chat{
    static let mock: Chat = .init(id: UUID().uuidString, lastMessage: .init(message: .mocks.first!), participants: ["1", "2"])
}


//enum RecipientType: String, Codable, Equatable {
//    case sent
//    case received
//}
//
//extension RecipientType {
//
//    var backgroundColor: Color {
//        switch self {
//        case .sent:
//            return .green
//        case .received:
//            return Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
//        }
//    }
//
//    var textColor: Color {
//        switch self {
//        case .sent:
//            return .white
//        case .received:
//            return .black
//        }
//    }
//}
