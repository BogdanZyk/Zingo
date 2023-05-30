//
//  AppRoute+View.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import SwiftUI


extension View {
//    func withAppRouter() -> some View {
//        navigationDestination(for: RouterDestination.self) { destination in
//            switch destination{
//            case .userProfile(let id):
//                UserProfile(userId: id)
//            }
//        }
//    }
    
    
    func withFullScreenRouter(fullScreen: Binding<FullScreenDestination?>) -> some View{
        fullScreenCover(item: fullScreen) { type in
            switch type{
            case .createNewPost(let user):
                PostEditorView(currentUser: user)
            case .editProfile(let manager):
                EditProfileView(userManager: manager)
            }
        }
    }
}
