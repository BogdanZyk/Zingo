//
//  CurrentUserProfileView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import SwiftUI

struct CurrentUserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProfileViewModel
    @State private var showConfirmationDialog: Bool = false
    @State private var pickerType: ImagePickerType = .photoLib
    @State private var showPicker: Bool = false
    
    init(userId: String?){
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let user = viewModel.user{
                ProfileContentViewComponent(user: user, isCurrentUser: viewModel.isCurrentUser, onTapAvatar: showConfirm, onTapBanner: showConfirm, onTapEdit: {}, onChangeTab: {_ in })
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
        .overlay(alignment: .topTrailing) {
            profileActionButton
        }
        .imagePicker(pickerType: pickerType, show: $showPicker, imagesData: $viewModel.imagesData, selectionLimit: 1)
        .confirmationDialog("", isPresented: $showConfirmationDialog) {
            Button("Camera") {
                pickerType = .camera
                showPicker.toggle()
            }
            Button("Photo") {
                pickerType = .photoLib
                showPicker.toggle()
            }
        }
    }
}

struct CurrentUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentUserProfileView(userId: "fTSwHTmYHkeYvfsWASMpEDlwGmg2")
    }
}



extension CurrentUserProfileView{
    
    
    private func showConfirm(){
        showPicker.toggle()
    }
        
    @ViewBuilder
    private var profileActionButton: some View{
        if viewModel.isCurrentUser{
            VStack(spacing: 20){
                IconButton(icon: .letter) {}
                IconButton(icon: .bookmark) {}
            }
            .padding(.trailing)
        }
    }
}

enum ProfileTab: String, CaseIterable{
    case posts, stories, liked, tagged
}
