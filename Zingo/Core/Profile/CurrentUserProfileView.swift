//
//  CurrentUserProfileView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import SwiftUI

struct CurrentUserProfileView: View {
    @EnvironmentObject private var router: MainRouter
    @ObservedObject var userManager: CurrentUserManager
    @State private var showConfirmationDialog: Bool = false
    @State private var pickerType: ImagePickerType = .photoLib
    @State private var showPicker: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let user = userManager.user{
                ProfileContentViewComponent(
                    user: user,
                    currentUserId: userManager.user?.id,
                    onTapAvatar: {onSelectedImage(.avatar)},
                    onTapBanner: {onSelectedImage(.banner)},
                    onTapEdit: onTapEdit)
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
        .overlay(alignment: .topTrailing) {
            profileActionButton
        }
        .imagePicker(pickerType: pickerType, show: $showPicker, imagesData: $userManager.imagesData, selectionLimit: 1, onDismiss: userManager.uploadImage)
        .confirmationDialog(userManager.selectedImageType.title, isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Camera") {
                selectedPicker(.camera)
            }
            Button("Photo") {
                selectedPicker(.photoLib)
            }
        }
        .navigationDestination(for: RouterDestination.self) { destination in
            switch destination{
            case .userProfile(let id):
                UserProfile(userId: id)
            case .followerFollowing(let user, let tab):
                FollowingsFollowersView(user: user, tab: tab)
                    .environmentObject(userManager)
            case .chats:
                ChatView()
            case .dialog(let conversation):
                DialogView(participant: conversation.conversationUser, chatId: conversation.id)
            case .dialogForId(let id):
                DialogView(participantId: id)
            }
        }
    }
}

struct CurrentUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentUserProfileView(userManager: CurrentUserManager())
            .environmentObject(MainRouter())
    }
}



extension CurrentUserProfileView{
    
    @ViewBuilder
    private var profileActionButton: some View{
            VStack(spacing: 20){
                IconButton(icon: .gear) {}
                IconButton(icon: .letter) {
                    router.navigate(to: .chats)
                }
            }
            .padding(.trailing)
    }
    
    private func selectedPicker(_ type: ImagePickerType){
        userManager.imagesData = []
        pickerType = type
        showPicker.toggle()
    }
    
    private func onSelectedImage(_ type: ProfileImageType){
        userManager.selectedImageType = type
        showConfirmationDialog.toggle()
    }
    
    private func onTapEdit(){
        router.setFullScreen(.editProfile(userManager))
    }
}

enum ProfileTab: String, CaseIterable{
    case posts, stories, liked, tagged
}
