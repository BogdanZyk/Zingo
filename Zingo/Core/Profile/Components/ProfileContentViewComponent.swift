//
//  ProfileContentViewComponent.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct ProfileContentViewComponent: View {
    let user: User
    var isCurrentUser: Bool
    @Namespace private var animation
    @State private var currentTab: ProfileTab = .posts
    
    var onTapAvatar: (() -> Void)?
    var onTapBanner: (() -> Void)?
    var onTapEdit: (() -> Void)?
    var onTapFollow: (() -> Void)?
    let onChangeTab: (ProfileTab) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottom){
                bgImage
                userAvatar
            }
            VStack(spacing: 16) {
                userInfo
                    .padding(.top, 75)
                followerSection
                
                underlineTabbarView
                
                tabViewSection
            }
            .padding(.horizontal)
        }
    }
}

struct ProfileContentViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView{
            ProfileContentViewComponent(user: User.mock, isCurrentUser: false, onChangeTab: {_ in})
        }
        .background(Color.darkBlack)
    }
}


extension ProfileContentViewComponent{
    private var bgImage: some View{
        Group{
            if let image = user.bannerImage?.fullPath{
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
                    if isCurrentUser{
                        Button {
                            onTapBanner?()
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
    
    private var userAvatar: some View{
        ZStack{
            Circle()
                .fill(Color.darkGray)
            .frame(width: 150, height: 150)
            .overlay{
                Circle()
                    .strokeBorder(LinearGradient.primaryGradient, lineWidth: 2.5)
            }
            UserAvatarView(image: user.profileImage?.fullPath)
                .onTapGesture {
                   onTapAvatar?()
                }
        }
        .offset(y: 75)
    }
    
    
    private var userInfo: some View{
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
            }
//            else if isCurrentUser{
//                Button {
//
//                } label: {
//                    Text("Add bio")
//                        .font(.body)
//                        .foregroundColor(.accentPink)
//                }
//            }
        }
        .foregroundColor(.white)
    }
    
    
    private var followerSection: some View{
        HStack(alignment: .bottom, spacing: 16){
            followerLabel(label: "Followers", value: user.followersCount)
            Spacer()
            followerLabel(label: "Following", value: user.followingsCount)
            Spacer()
            
            if isCurrentUser{
                ButtonView(label: "Edit profile", type: .border, font: .headline.bold()) {
                    onTapEdit?()
                }
            }else{
                ButtonView(label: "Follow", type: .primary, font: .title3.bold()) {
                    
                }
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
                        onChangeTab(tab)
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
}
