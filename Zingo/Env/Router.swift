//
//  Router.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import Combine
import Foundation
import SwiftUI
import FirebaseAuth

enum RouterDestination: Hashable {
    case userProfile(id: String)
    case chats
    case dialog(Conversation)
    case dialogForId(String)
}

enum FullScreenDestination: Identifiable{
    
    case createNewPost(User?)
    case editProfile(CurrentUserManager)
    
    
    var id: Int{
        switch self {
        case .createNewPost: return 0
        case .editProfile: return 1
        }
    }
}


enum PopupNotify: String, Identifiable{
    case successfullyPost = "successfullyPost"
    
    var id: String{
        self.rawValue
    }
    
    var title: String{
        switch self {
        case .successfullyPost: return "Your post was successfully published!"
        }
    }
    var color: Color{
        switch self {
        case .successfullyPost: return .accentPink
        }
    }
}

enum SheetDestination {
  case newStatusEditor
}




final class MainRouter: ObservableObject {

    @Published var pathDestination = PathDestination()
    @Published var presentedSheet: SheetDestination?
    @Published var fullScreen: FullScreenDestination?
    @Published var popup: PopupNotify?
    @Published var tab: Tab = .feed
    @Published var hiddenTabView: Bool = false
    @Published var userSession: FirebaseAuth.User?
    private let cancelBag = CancelBag()
    let authManager = AuthenticationManager.share
    
    init() {
        startSubsUserSession()
        setupNcPublisher()
    }
    
    func navigate(to: RouterDestination) {
        switch tab {
        case .feed:
            pathDestination.feed.append(to)
        case .search:
            pathDestination.search.append(to)
        case .notification:
            pathDestination.notification.append(to)
        case .profile:
            pathDestination.profile.append(to)
        default: break
        }
    }
    
    func popLast(){
        switch tab {
        case .feed:
            pathDestination.feed.removeLast()
        case .search:
            pathDestination.search.removeLast()
        case .notification:
            pathDestination.notification.removeLast()
        case .profile:
            pathDestination.profile.removeLast()
        default: break
        }
    }
    
    func setTab(_ tab: Tab){
        self.tab = tab
    }
    
    func setFullScreen(_ type: FullScreenDestination){
        self.fullScreen = type
    }
    
    private func startSubsUserSession(){
        authManager.$userSession
            .receive(on: DispatchQueue.main)
            .sink { session in
            self.userSession = session
        }
        .store(in: cancelBag)
    }
    
    private func setupNcPublisher(){
        nc.publisher(for: .successfullyPost)
            .delay(for: 0.5, scheduler: RunLoop.main)
            .sink {[weak self] notification in
                guard let self = self else {return}
                self.popup = .init(rawValue: notification.name.rawValue)
            }
            .store(in: cancelBag)
    }
}


extension MainRouter{
    struct PathDestination{
        var feed = [RouterDestination]()
        var search = [RouterDestination]()
        var notification = [RouterDestination]()
        var profile = [RouterDestination]()
    }
}


