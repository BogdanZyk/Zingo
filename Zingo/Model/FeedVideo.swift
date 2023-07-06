//
//  FeedVideo.swift
//  Zingo
//
//  Created by Bogdan Zykov on 26.06.2023.
//

import Foundation

struct FeedVideo: Identifiable, Codable{
    
    var id: String = UUID().uuidString
    let owner: ShortUser
    let video: StoreVideo
    var description: String?
    var comments: Int = 0
    var createdAt: Date = .now
    var likedUserIds: [String] = []
    var enableComments: Bool = true
    var isDisabledComments: Bool = false
    var isHiddenLikesCount: Bool = false
    
    var likeCount: Int{
        likedUserIds.count
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case video
        case description
        case comments
        case createdAt
        case likedUserIds
        case isDisabledComments
        case isHiddenLikesCount
    }
    
    func didLike(_ userId: String?) -> Bool{
        guard let userId else { return false }
        return likedUserIds.contains(userId)
    }
}

extension FeedVideo{
    
    static let mock = FeedVideo(owner: .init(user: .mock), video: .init(path: "", fullPath: ""))
    
}
