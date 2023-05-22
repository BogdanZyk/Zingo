//
//  ProfileView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Namespace private var animation
    @State var currentTab: ProfileTab = .posts
    @StateObject private var viewModel: ProfileViewModel
    @State private var showConfirmationDialog: Bool = false
    @State private var pickerType: ImagePickerType = .photoLib
    @State private var showPicker: Bool = false
    var userId: String?
    
    init(userId: String?){
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let user = viewModel.user{
                content(user)
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userId: "fTSwHTmYHkeYvfsWASMpEDlwGmg2")
    }
}

extension ProfileView{
    
    
    private func content(_ user: User) -> some View{
        VStack(spacing: 16) {
            ZStack(alignment: .bottom){
                bgImage(user.bannerImage)
                userAvatar(user.profileImageUrl)
            }
            VStack(spacing: 16) {
                userInfo(user)
                    .padding(.top, 75)
                followerSection(user)
                
                underlineTabbarView
                
                tabViewSection
            }
            .padding(.horizontal)
        }
    }
    
    
}


extension ProfileView{
    
    private func bgImage(_ image: String?) -> some View{
        Group{
            if let image{
                GeometryReader{ geo -> AnyView in
                    AnyView(
                        LazyNukeImage(strUrl: image, resizingMode: .aspectFill, loadPriority: .high)
                            .frame(height: geo.height)
                            .offset(y: geo.verticalOffset)
                    )
                }
                .frame(height: 100)
            }else{
                ZStack(alignment: .top){
                    Color.darkGray
                    if viewModel.isCurrentUser{
                        Button {
                            showConfirmationDialog.toggle()
                        } label: {
                            Text("Add bunner image")
                                .foregroundColor(.lightGray)
                        }
                        .padding(.top, 26)
                    }
                }
            }
        }
    }
    
    private func userAvatar(_ image: String?) -> some View{
        ZStack{
            Circle()
                .fill(Color.darkGray)
            .frame(width: 150, height: 150)
            .overlay{
                Circle()
                    .strokeBorder(LinearGradient.primaryGradient, lineWidth: 2.5)
            }
            UserAvatarView(image: image)
                .onTapGesture {
                    showConfirmationDialog.toggle()
                }
        }
        .offset(y: 75)
    }
    
    
    private func userInfo(_ user: User) -> some View{
        VStack(spacing: 10) {
            Text(user.userName)
                .font(.title2.bold())
            if let location = user.location{
                Text(location)
                    .font(.body)
                    .foregroundColor(.lightGray)
            }
            if let bio = user.bio{
                Text(bio)
                    .font(.body.weight(.medium))
            } else if viewModel.isCurrentUser{
                Button {
                    
                } label: {
                    Text("Add bio")
                        .font(.body)
                        .foregroundColor(.accentPink)
                }
            }
        }
        .foregroundColor(.white)
    }
    
    
    private func followerSection(_ user: User) -> some View{
        HStack(alignment: .bottom, spacing: 16){
            followerLabel(label: "Followers", value: user.followersCount)
            Spacer()
            followerLabel(label: "Following", value: user.followingsCount)
            Spacer()
            ButtonView(label: "Edit profile", type: .border, font: .headline.bold()) {
                
            }
        }
        .hLeading()
    }
    
    
    private func followerLabel(label: String, value: Int) -> some View{
        VStack(alignment: .leading, spacing: 4){
            Text(verbatim: String(value))
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.body)
                .foregroundColor(.lightGray)
        }
        .padding(.top, 24)
    }
    
    
    private var underlineTabbarView: some View{
        HStack{
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Text(tab.rawValue.capitalized)
                    .hCenter()
                    .padding(.vertical, 10)
                    .bold(tab == currentTab)
                    .onTapGesture {
                        currentTab = tab
                    }
                    .overlay(alignment: .bottom) {
                        if currentTab == tab{
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "ProfileTab", in: animation)
                        }
                    }
            }
        }
        .foregroundColor(.white)
        .padding(.vertical)
        .animation(.easeInOut(duration: 0.2), value: currentTab)
    }
    
    @ViewBuilder
    private var tabViewSection: some View{
        switch currentTab{
            
        case .posts:
            LazyVStack(spacing: 16) {
                ForEach(Post.mockPosts) { post in
                    PostView(post: post)
                }
            }
        case .stories:
            Text("stories")
        case .liked:
            Text("liked")
        case .tagged:
            Text("tagged")
        }
    }
    
    @ViewBuilder
    private var backButton: some View{
        if !viewModel.isCurrentUser{
            IconButton(icon: .arrowLeft) {
                dismiss()
            }
            .padding(.leading)
        }
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
