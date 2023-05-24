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
    var comments: Int = 0
    var images: [StoreImage]
    var createdAt: Date
    var likedUserIds: [String] = []
    
    struct Owner: Codable{
        let id: String
        let name: String
        let image: String?
        
        
        init(user: User){
            self.id = user.id
            self.name = user.userName
            self.image = user.profileImage?.fullPath
        }
    }
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case caption
        case likedUserIds
        case comments
        case images
        case createdAt
    }
}


extension Post{
    
    var likeCount: Int{
        likedUserIds.count
    }
    
    func didLike(_ userId: String?) -> Bool{
        guard let userId else {return false}
        return likedUserIds.contains(userId)
    }
}

extension Post{
    static let mockPosts = [
        Post(id: UUID().uuidString,
             owner: Owner(user: User.mock),
             caption: "“If you think you are too small to make a difference, try sleeping with a mosquito.” ~ Dalai Lama",
             comments: 34,
             images: [],
             createdAt: Date.now),
        Post(id: UUID().uuidString,
             owner: Owner(user: User.mock),
             caption: nil,
             comments: 34,
             images: [.init(path: "", fullPath: "https://i.etsystatic.com/30097568/r/il/c7f1a0/3513889975/il_570xN.3513889975_lfe4.jpg")],
             createdAt: Date.now)
    ]
}
