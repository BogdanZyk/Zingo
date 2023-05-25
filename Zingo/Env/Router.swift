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
//  case accountDetailWithAccount(account: Account)
//  case accountSettingsWithAccount(account: Account, appAccount: AppAccount)
//  case statusDetail(id: String)
//  case statusDetailWithStatus(status: Status)
//  case remoteStatusDetail(url: URL)
//  case conversationDetail(conversation: Conversation)
//  case hashTag(tag: String, account: String?)
//  case list(list: Models.List)
//  case followers(id: String)
//  case following(id: String)
//  case favoritedBy(id: String)
//  case rebloggedBy(id: String)
//  case accountsList(accounts: [Account])
//  case trendingTimeline
//  case tagsList(tags: [Tag])
}

enum FullScreenDestination: Identifiable{
    
    case createNewPost(User?)
    
    var id: Int{
        switch self {
        case .createNewPost: return 0
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
//  case editStatusEditor(status: Status)
//  case replyToStatusEditor(status: Status)
//  case quoteStatusEditor(status: Status)
//  case mentionStatusEditor(account: Account, visibility: Models.Visibility)
//  case listEdit(list: Models.List)
//  case listAddAccount(account: Account)
//  case addAccount
//  case addRemoteLocalTimeline
//  case statusEditHistory(status: String)
//  case settings
//  case accountPushNotficationsSettings
//  case report(status: Status)
//  case shareImage(image: UIImage, status: Status)

//  public var id: String {
//    switch self {
//    case .editStatusEditor, .newStatusEditor, .replyToStatusEditor, .quoteStatusEditor,
//         .mentionStatusEditor, .settings, .accountPushNotficationsSettings:
//      return "statusEditor"
//    case .listEdit:
//      return "listEdit"
//    case .listAddAccount:
//      return "listAddAccount"
//    case .addAccount:
//      return "addAccount"
//    case .addRemoteLocalTimeline:
//      return "addRemoteLocalTimeline"
//    case .statusEditHistory:
//      return "statusEditHistory"
//    case .report:
//      return "report"
//    case .shareImage:
//      return "shareImage"
//    }
//  }
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


