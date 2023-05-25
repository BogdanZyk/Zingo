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

struct Chat: Identifiable, Codable{
    let id: String
    var lastMessage: ShortMessage?
    var unreadCount: Int = 0
    var participants: [String] = []
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case lastMessage
        case unreadCount
        case participants
        case createdAt
    }
}

struct ShortMessage: Identifiable, Codable{
    let id: String
    var text: String
    var senderId: String
    var createdAt: Date = Date()
    
    
    init(message: Message){
        self.id = message.id
        self.text = message.text
        self.senderId = message.senderId
        self.createdAt = message.createdAt
    }
}

struct Message: Identifiable, Codable{
    let id: String
    let chatId: String
    var text: String
    var senderId: String
    var recipientId: String
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId
        case text
        case senderId
        case recipientId
        case createdAt
    }
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
