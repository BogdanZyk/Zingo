//
//  UserProfile.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct UserProfile: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: UserViewModel
    @State private var showDialogView: Bool = false
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
        .navigationDestination(isPresented: $showDialogView) {
            if let id = viewModel.user?.id{
                DialogView(participantId: id)
            }
        }
        .navigationDestination(for: RouterDestination.self) { destination in
            switch destination{
            case .userProfile(let id):
                UserProfile(userId: id)
            case .chats: EmptyView()
            case .dialog(let conversation):
                DialogView(participant: conversation.conversationUser, chatId: conversation.id)
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
            dismiss()
        }
        .padding(.leading)
    }
    
    private func onTapMessage(){
        if fromDialog{
            dismiss()
        }
        showDialogView.toggle()
    }
}
