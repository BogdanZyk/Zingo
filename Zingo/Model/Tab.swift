//
//  Tab.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation


enum Tab: Int, CaseIterable{
    
    case feed, search, create, videoFeed, profile
    
    var image: String{
        switch self {
        case .feed: return Icon.home.rawValue
        case .search: return Icon.search.rawValue
        case .create: return Icon.plus.rawValue
        case .videoFeed: return Icon.videoFeed.rawValue
        case .profile: return Icon.profile.rawValue
        }
    }
}
