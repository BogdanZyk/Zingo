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
    var followersCount: Int = 0
    var followingsCount: Int = 0
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName
        case email
        case profileImage
        case bannerImage
        case fullName
        case bio
        case location
        case followersCount
        case followingsCount
    }
    
}

extension User{
    static let mock = User(id: UUID().uuidString,
                           userName: "Tester",
                           email: "test@test.cpm",
                           profileImage: .init(path: "", fullPath: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_KIEkMvsIZEmzG7Og_h3SJ4T3HsE2rqm3_w&usqp=CAU"),
                           fullName: "Alex Tsimikas",
                           bio: "Writer by Profession. Artist by Passion!",
                           location: "Brooklyn, NY",
                           followersCount: 123,
                           followingsCount: 24)
}
