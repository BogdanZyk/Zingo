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
    case followerFollowing(user: User, tab: FollowTab)
}

enum FullScreenDestination: Identifiable{
    
    case createNewPost(User?)
    case createStory(User?)
    case editProfile(CurrentUserManager)
    case feedCameraView(VideoFileManager)
    
    var id: Int{
        switch self {
        case .createNewPost: return 0
        case .editProfile: return 1
        case .createStory: return 2
        case .feedCameraView: return 3
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

struct StoryRouter{
    var show: Bool = false
    var stories: [Story] = []
    var selectedId: String?
}


final class MainRouter: ObservableObject {

    @Published var pathDestination = PathDestination()
    @Published var presentedSheet: SheetDestination?
    @Published var fullScreen: FullScreenDestination?
    @Published var popup: PopupNotify?
    @Published var tab: Tab = .feed
    @Published var hiddenTabView: Bool = false
    @Published var userSession: FirebaseAuth.User?
    @Published var storyRouter = StoryRouter()
    
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
        case .videoFeed:
            pathDestination.videoFeed.append(to)
        case .profile:
            pathDestination.profile.append(to)
        default: break
        }
    }
    
    func popLast(){
        switch tab {
        case .feed:
            pathDestination.feed.removeLastOptionally()
        case .search:
            pathDestination.search.removeLastOptionally()
        case .videoFeed:
            pathDestination.videoFeed.removeLastOptionally()
        case .profile:
            pathDestination.profile.removeLastOptionally()
        default: break
        }
    }
    
    func setTab(_ tab: Tab){
        if tab == self.tab{
            resetPath()
        }else{
            self.tab = tab
        }
    }
    
    func setFullScreen(_ type: FullScreenDestination){
        self.fullScreen = type
    }
    
    func showStory(_ stories: [Story], selectedId: String?){
        storyRouter.stories = stories
        storyRouter.selectedId = selectedId
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self.storyRouter.show = true
        }
    }
    
    private func startSubsUserSession(){
        authManager.$userSession
            .receive(on: DispatchQueue.main)
            .sink { session in
            self.userSession = session
        }
        .store(in: cancelBag)
    }
    
    private func resetPath(){
        switch tab {
        case .feed:
            pathDestination.feed.removeAll()
        case .search:
            pathDestination.search.removeAll()
        case .videoFeed:
            pathDestination.videoFeed.removeAll()
        case .profile:
            pathDestination.profile.removeAll()
        default: break
        }
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
        var videoFeed = [RouterDestination]()
        var profile = [RouterDestination]()
    }
}


