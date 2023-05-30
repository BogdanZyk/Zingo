//
//  User.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation


struct User: Identifiable, Codable{
    
    let id: String
    var userName: String
    var email: String
    var profileImage: StoreImage?
    var bannerImage: StoreImage?
    var fullName: String?
    var bio: String?
    var location: String?
    var followers: [String] = []
    var followings: [String] = []
    var gender: Gender? = .over
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName
        case email
        case profileImage
        case bannerImage
        case fullName
        case bio
        case location
        case followers
        case followings
        case gender
    }
    
    var followersCount: Int{
        followers.count
    }
    var followingsCount: Int{
        followings.count
    }
    
    func isFollow(for id: String) -> Bool{
        followers.contains(id)
    }
    
    func isFollowing(for id: String) -> Bool{
        followings.contains(id)
    }
}

extension User{
    static let mock = User(id: "fTSwHTmYHkeYvfsWASMpEDlwGmg2",
                           userName: "Tester",
                           email: "test@test.cpm",
                           profileImage: .init(path: "", fullPath: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_KIEkMvsIZEmzG7Og_h3SJ4T3HsE2rqm3_w&usqp=CAU"),
                           fullName: "Alex Tsimikas",
                           bio: "Writer by Profession. Artist by Passion!",
                           location: "Brooklyn, NY")
}


extension User{
    
    enum Gender: String, CaseIterable, Codable{
        case male, female, over
    }
    
    struct UserInfo{
        let id: String
        var userName: String
        var fullName: String
        var bio: String
        var gender: Gender
        var location: String
        
        func getDict() -> [String: Any]{
            [
                User.CodingKeys.userName.rawValue: userName,
                User.CodingKeys.fullName.rawValue: fullName,
                User.CodingKeys.bio.rawValue: bio,
                User.CodingKeys.gender.rawValue: gender.rawValue,
                User.CodingKeys.location.rawValue: location,
            ]
        }
    }
    
    
    func getInfo() -> UserInfo{
        .init(id: id, userName: userName, fullName: fullName ?? "", bio: bio ?? "", gender: gender ?? .over, location: location ?? "")
    }
}
