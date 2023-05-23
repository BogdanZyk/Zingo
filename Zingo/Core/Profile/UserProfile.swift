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
    
    init(userId: String?){
        self._viewModel = StateObject(wrappedValue: UserViewModel(userId: userId))
    }
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let user = viewModel.user{
                ProfileContentViewComponent(user: user, isCurrentUser: viewModel.isCurrentUser, onTapFollow: {}, onChangeTab: {_ in })
            }else{
                ProgressView()
                    .hCenter()
                    .padding(.top, 50)
                    .tint(.accentPink)
            }
        }
        .foregroundColor(.white)
        .background(Color.darkBlack)
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            backButton
        }
    }
}

struct UserProfile_Previews: PreviewProvider {
    static var previews: some View {
        UserProfile(userId: "fTSwHTmYHkeYvfsWASMpEDlwGmg2")
    }
}

extension UserProfile{
    
    
    @ViewBuilder
    private var backButton: some View{
        if !viewModel.isCurrentUser{
            IconButton(icon: .arrowLeft) {
                dismiss()
            }
            .padding(.leading)
        }
    }
}
