//
//  ProfileContentViewComponent.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct ProfileContentViewComponent: View {
    @State var currentTab: ProfileTab = .posts
    @EnvironmentObject var router: MainRouter
    @StateObject private var viewModel: ProfileContentViewModel
    let user: User
    var currentUserId: String?
    
    var onTapAvatar: (() -> Void)?
    var onTapBanner: (() -> Void)?
    var onTapEdit: (() -> Void)?
    var onTapFollow: ((Bool) -> Void)?
    var onTapMessage: (() -> Void)?
    
    private var isFollow: Bool{
        guard let currentUserId else {return false}
        return user.isFollow(for: currentUserId)
    }
    
    init(user: User,
         currentUserId: String? = nil,
         onTapAvatar: (() -> Void)? = nil,
         onTapBanner: (() -> Void)? = nil,
         onTapEdit: (() -> Void)? = nil,
         onTapFollow: ((Bool) -> Void)? = nil,
         onTapMessage: (() -> Void)? = nil) {
        
        self._viewModel = StateObject(wrappedValue: ProfileContentViewModel(userId: user.id))
        self.user = user
        self.currentUserId = currentUserId
        self.onTapAvatar = onTapAvatar
        self.onTapBanner = onTapBanner
        self.onTapEdit = onTapEdit
        self.onTapFollow = onTapFollow
        self.onTapMessage = onTapMessage
    }
    
    var isCurrentUser: Bool{
        user.id == currentUserId
    }
    
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
                
                underlineTabView
                
                tabViewSection
            }
            .padding(.horizontal)
        }
    }
}

struct ProfileContentViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView{
            ProfileContentViewComponent(user: User.mock)
        }
        .background(Color.darkBlack)
        .environmentObject(MainRouter())
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
                        Text("Add bunner image")
                            .foregroundColor(.lightGray)
                            .padding(.top, 26)
                    }
                }
            }
        }
        
        .onTapGesture {
            if isCurrentUser{
                onTapBanner?()
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
            HStack {
                Text(user.userName)
                    .font(.title2.bold())
                if !isCurrentUser{
                    IconButton(icon: .letter) {
                        onTapMessage?()
                    }
                }
            }
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
                ButtonView(label: isFollow ? "Unfollow" : "Follow", type: isFollow ? .border : .primary, font: .title3.bold()) {
                    onTapFollow?(isFollow)
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
    
    
    private var underlineTabView: some View{
        ProfileContentTabView(currentTab: $currentTab)
    }
    
    @ViewBuilder
    private var tabViewSection: some View{
        switch currentTab{
            
        case .posts:
            userPostsList
        case .stories:
            Text("stories")
        case .liked:
            Text("liked")
        case .tagged:
            Text("tagged")
        }
    }

    private var userPostsList: some View{
        PostsListView(router: router, posts: $viewModel.userPosts, shouldNextPageLoader: viewModel.shouldNextPageLoader, currentUserId: currentUserId ?? "", fetchNextPage: viewModel.fetchPosts)
    }
}


struct ProfileContentTabView: View{
    @Namespace private var animation
    @Binding var currentTab: ProfileTab
    var body: some View{
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
}
