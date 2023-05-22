//
//  User.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation


struct User: Identifiable, Codable{
    
    var id: String
    var userName: String
    var email: String
    var profileImageUrl: String?
    var fullName: String?
    var bio: String?
    var location: String?
    
}


extension User{
    static let mock = User(id: UUID().uuidString,
                           userName: "Tester",
                           email: "test@test.cpm",
                           profileImageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_KIEkMvsIZEmzG7Og_h3SJ4T3HsE2rqm3_w&usqp=CAU",
                           fullName: "Alex Tsimikas",
                           bio: "Writer by Profession. Artist by Passion!",
                           location: "Brooklyn, NY")
}
