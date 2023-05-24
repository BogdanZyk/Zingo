//
//  Comment.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import Foundation

struct Comment: Identifiable, Codable{
    var id: String
    let postId: String
    let owner: Post.Owner
    var text: String?
    var likedUserIds: [String] = []
    var createdAt: Date = Date()
    var image: StoreImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId
        case owner
        case text
        case likedUserIds
        case createdAt
        case image
    }
}

extension Comment{
    
    var likeCount: Int{
        likedUserIds.count
    }
    
    func didLike(_ userId: String?) -> Bool{
        guard let userId else {return false}
        return likedUserIds.contains(userId)
    }
    
}

extension Comment{
    static let mocks: [Comment] = [
        .init(id: UUID().uuidString, postId: "", owner: .init(user: User.mock), text: "Comment 1"),
        .init(id: UUID().uuidString, postId: "", owner: .init(user: User.mock), text: "Comment 2"),
        .init(id: UUID().uuidString, postId: "", owner: .init(user: User.mock), text: "Comment 3", image: Post.mockPosts.last?.images.first)]
}
