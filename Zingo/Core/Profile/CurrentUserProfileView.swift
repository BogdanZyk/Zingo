//
//  CurrentUserProfileView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import SwiftUI

struct CurrentUserProfileView: View {
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
                    onTapEdit: {})
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
            default: EmptyView()
            }
        }
    }
}

struct CurrentUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentUserProfileView(userManager: CurrentUserManager())
    }
}



extension CurrentUserProfileView{
    
    @ViewBuilder
    private var profileActionButton: some View{
            VStack(spacing: 20){
                IconButton(icon: .letter) {}
                IconButton(icon: .bookmark) {}
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
}

enum ProfileTab: String, CaseIterable{
    case posts, stories, liked, tagged
}
