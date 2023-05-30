//
//  EditProfileView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 29.05.2023.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var userManager: CurrentUserManager
    @StateObject private var viewModel: EditProfileViewModel
    @State private var showConfirmationDialog: Bool = false
    @State private var pickerType: ImagePickerType = .photoLib
    @State private var showPicker: Bool = false
    @State private var showLoader: Bool = false
        
    init(userManager: CurrentUserManager){
        self._userManager = StateObject(wrappedValue: userManager)
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(currentUser: userManager.user!))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                avatarSection
                listView
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.darkBlack)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit profile")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .primaryAction) {
                    if showLoader {
                        ProgressView()
                    }else{
                        Button("Save") {
                            Task{
                                await save()
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: EditRout.self) { type in
                EditUserInfoView(viewModel: viewModel, type: type)
            }
        }
        .disabled(showLoader)
        .preferredColorScheme(.dark)
        .imagePicker(pickerType: pickerType, show: $showPicker, imagesData: $userManager.imagesData, selectionLimit: 1)
        .confirmationDialog(userManager.selectedImageType.title, isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Camera") {
                selectedPicker(.camera)
            }
            Button("Photo") {
                selectedPicker(.photoLib)
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(userManager: CurrentUserManager())
    }
}

extension EditProfileView{
    
    
    private var avatarSection: some View{
        VStack {
            Group{
                if let image = userManager.imagesData.first?.image{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }else{
                    UserAvatarView(image: userManager.user?.profileImage?.fullPath, size: .init(width: 100, height: 100))
                }
            }
            Text("Change avatar")
                .font(.body.weight(.medium))
            Divider()
        }
        .hCenter()
        .onTapGesture {
            onSelectedImage(.avatar)
        }
    }
    
    func navLink(_ type: EditRout) -> some View{
        NavigationLink(value: type) {
            VStack(alignment: .leading) {
                HStack(spacing: 30) {
                    Text(type.title)
                        .font(.body.weight(.light))
                        .frame(width: 100, alignment: .leading)
                    Group{
                        switch type{
                        case .name:
                            Text(viewModel.userInfo.fullName.isEmpty ? "Add your name" : viewModel.userInfo.fullName)
                        case .bio:
                            Text(viewModel.userInfo.bio.isEmpty ? "About you" : viewModel.userInfo.bio)
                        case .username:
                            Text(viewModel.userInfo.userName)
                        case .gender:
                            Text(viewModel.userInfo.gender.rawValue.capitalized)
                        }
                    }
                    .font(.headline.weight(.medium))
                    
                    Spacer()
                }
                Divider()
            }
            .foregroundColor(.white)
        }
    }
    
    private var listView: some View{
        let routes: [EditRout] =
        [.username(userManager.user?.userName), .name(userManager.user?.fullName), .bio(userManager.user?.bio), .gender(userManager.user?.gender)]
        return ForEach(routes) { type in
            navLink(type)
        }
    }
    
    enum EditRout: Hashable, Identifiable{
        
        case name(String?), username(String?), bio(String?), gender(User.Gender?)
        
        var title: String{
            switch self{
            case .name: return "Name"
            case .username: return "Username"
            case .bio: return "Bio"
            case .gender: return "Gender"
            }
        }
        
        var id: Int{
            switch self{
            case .name: return 0
            case .username: return 1
            case .bio: return 2
            case .gender: return 3
            }
        }
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
    
    private func save() async{
        showLoader = true
        
        await userManager.uploadImage()
        await viewModel.updateUserInfo()
        
        showLoader = false
        
        
        dismiss()
    }
}



