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
  case accountDetail(id: String)
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

enum FullScreenDestination: Identifiable, Hashable{
    case createNewPost
    
    var id: Int{
        switch self {
        case .createNewPost: return 0
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




class MainRouter: ObservableObject {

    @Published var path: [RouterDestination] = []
    @Published var presentedSheet: SheetDestination?
    @Published var fullScreen: FullScreenDestination?
    @Published var tab: Tab = .home
    @Published var userSession: FirebaseAuth.User?
    private let cancelBag = CancelBag()
    let authManager = AuthenticationManager.share
    
    init() {
        startSubsUserSession()
    }
    
    func navigate(to: RouterDestination) {
        path.append(to)
    }
    
    
    func setTab(_ tab: Tab){
        self.tab = tab
    }
    
    private func startSubsUserSession(){
        authManager.$userSession
            .receive(on: DispatchQueue.main)
            .sink { session in
            self.userSession = session
        }
        .store(in: cancelBag)
    }
}


