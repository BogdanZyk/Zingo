//
//  Story.swift
//  Zingo
//
//  Created by Bogdan Zykov on 30.05.2023.
//

import Foundation

struct Story: Codable, Identifiable{
    
    var id: String
    var creator: ShortUser
    var images: [StoreImage]
    var createdAt: Date = Date()
}

extension Story{
    
    
    static let mocks: [Story] = [.init(id: "1", creator: .init(user: .mock), images: StoreImage.mocks),
                                 .init(id: "2", creator: .init(user: .mock), images: StoreImage.mocks)]
    
}
