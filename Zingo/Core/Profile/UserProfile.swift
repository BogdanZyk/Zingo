//
//  UserProfile.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct UserProfile: View {
    @EnvironmentObject private var router: MainRouter
    @StateObject private var viewModel: UserViewModel
    var fromDialog: Bool = false
    init(userId: String?, fromDialog: Bool = false){
        self._viewModel = StateObject(wrappedValue: UserViewModel(userId: userId))
        self.fromDialog = fromDialog
    }
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let user = viewModel.user{
                ProfileContentViewComponent(
                    user: user,
                    currentUserId: viewModel.currentUserId,
                    onTapFollow: viewModel.followOrUnFollow,
                    onTapMessage: onTapMessage)
            }else{
                ProgressView()
                    .hCenter()
                    .padding(.top, 50)
                    .tint(.accentPink)
            }
        }
        .foregroundColor(.white)
        .bottomTabPadding()
        .background(Color.darkBlack)
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            backButton
        }
        .navigationDestination(for: RouterDestination.self) { destination in
            switch destination{
            case .userProfile(let id):
                UserProfile(userId: id)
            case .chats, .dialog: EmptyView()
            case .dialogForId(let id):
                DialogView(participantId: id)
            }
        }
    }
}

struct UserProfile_Previews: PreviewProvider {
    static var previews: some View {
        UserProfile(userId: "fTSwHTmYHkeYvfsWASMpEDlwGmg2")
            .environmentObject(MainRouter())
    }
}

extension UserProfile{
    @ViewBuilder
    private var backButton: some View{
        IconButton(icon: .arrowLeft) {
            router.popLast()
        }
        .padding(.leading)
    }
    
    private func onTapMessage(){
        if fromDialog{
            router.popLast()
        }
        if let id = viewModel.user?.id{
            router.navigate(to: .dialogForId(id))
        }
    }
}
