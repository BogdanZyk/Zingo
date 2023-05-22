//
//  Tab.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation


enum Tab: Int, CaseIterable{
    
    case home, search, create, notification, profile
    
    var image: String{
        switch self {
        case .home: return Icon.home.rawValue
        case .search: return Icon.search.rawValue
        case .create: return Icon.plus.rawValue
        case .notification: return Icon.notification.rawValue
        case .profile: return Icon.profile.rawValue
        }
    }
}
