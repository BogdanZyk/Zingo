//
//  Post.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation



struct Post: Identifiable, Codable{
    
    let id: String
    let owner: Owner
    let caption: String?
    var likes: Int
    var comments: Int
    var imageUrl: String?
    var createdAt: Date
    
    
    struct Owner: Codable{
        let id: String
        let name: String
        let image: String?
        
        
        init(user: User){
            self.id = user.id
            self.name = user.userName
            self.image = user.profileImageUrl
        }
    }
    
}

extension Post{
    static let mockPosts = [
        Post(id: UUID().uuidString,
             owner: Owner(user: User.mock),
             caption: "“If you think you are too small to make a difference, try sleeping with a mosquito.” ~ Dalai Lama",
             likes: 123,
             comments: 34,
             createdAt: Date.now),
        Post(id: UUID().uuidString,
             owner: Owner(user: User.mock),
             caption: nil,
             likes: 123,
             comments: 34,
             imageUrl: "https://i.etsystatic.com/30097568/r/il/c7f1a0/3513889975/il_570xN.3513889975_lfe4.jpg",
             createdAt: Date.now)
    ]
}
