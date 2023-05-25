//
//  Message.swift
//  Zingo
//
//  Created by Bogdan Zykov on 25.05.2023.
//

import Foundation

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
    
    func getRecipientType(currentUserId: String?) -> RecipientType{
        senderId == currentUserId ? .sent : .received
    }
}

extension Message{
    static let mocks: [Message] = [
        .init(id: UUID().uuidString, chatId: "1", text: "Hello!", senderId: "1", recipientId: "2"),
        .init(id: UUID().uuidString, chatId: "1", text: "Hi!", senderId: "2", recipientId: "1")
    ]
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
