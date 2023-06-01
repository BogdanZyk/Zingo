//
//  FollowingsFollowersView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 01.06.2023.
//

import SwiftUI

struct FollowingsFollowersView: View {
    @EnvironmentObject private var userManager: CurrentUserManager
    @EnvironmentObject private var router: MainRouter
    @Environment(\.dismiss) private var dismiss
    @State private var tab: FollowTab = .followers
    @StateObject private var viewModel: FollowingsFollowersViewModel
    let user: User
    
    
    var isCurrentUser: Bool{
        user.id == userManager.user?.id
    }
    
    init(user: User, tab: FollowTab) {
        self._viewModel = StateObject(wrappedValue: FollowingsFollowersViewModel(user: user))
        self.user = user
        self.tab = tab        
    }
    
    var body: some View {

        TabView(selection: $tab) {
            followersList
                .tag(FollowTab.followers)
            
            followingsList
                .tag(FollowTab.following)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.darkBlack)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            header
        }
    }
}

struct FollowingsFollowersView_Previews: PreviewProvider {
    static var previews: some View {
        FollowingsFollowersView(user: .mock, tab: .followers)
            .environmentObject(MainRouter())
            .environmentObject(CurrentUserManager())
    }
}


extension FollowingsFollowersView{
    private var header: some View{
        VStack(spacing: 6) {
            Text(user.userName)
                .font(.title3.bold())
                .hCenter()
                
                .overlay(alignment: .leading) {
                    IconButton(icon: .arrowLeft) {
                        dismiss()
                    }
                    .padding(.horizontal)
            }
            HStack{
                ForEach(FollowTab.allCases, id: \.self){tab in
                    Text("\(getCount(tab)) \(tab.rawValue.capitalized)")
                        .font(.body.bold())
                        .hCenter()
                        .opacity(tab == self.tab ? 1 : 0.5)
                        .padding(10)
                        .onTapGesture {
                            self.tab = tab
                        }
                }
            }
            CustomDivider()
        }
        .foregroundColor(.white)
        .background(Color.darkBlack)
    }
    
    private func getCount(_ type: FollowTab) -> Int{
        switch type{
        case .followers: return user.followersCount
        case .following: return user.followingsCount
        }
    }
    
    
    private var followersList: some View{
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.followers) { user in
                    userRowView(user)
                }
            }
            .padding()
        }
    }
    
    private var followingsList: some View{
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.followings) { user in
                    userRowView(user)
                }
            }
            .padding()
        }
    }
    
    
    private func userRowView(_ user: ShortUser) -> some View{
        HStack{
            HStack{
                UserAvatarView(image: user.image, size: .init(width: 50, height: 50))
                VStack {
                    Text(user.name)
                        .font(.body.bold())
                        .foregroundColor(.white)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                router.navigate(to: .userProfile(id: user.id))
            }
            Spacer()
   
            if tab == .followers{
                if isCurrentUser{
                    ButtonView(label: "Remove", type: .secondary, height: 32, font: .body.bold()) {
                        
                    }
                    .frame(width: 100)
                }else{
                    followButton(user)
                }
            }else{
                followButton(user)
            }
        }
    }
    
    
    @ViewBuilder
    private func followButton(_ user: ShortUser) -> some View{
        
        if user.id == userManager.user?.id{
            Text("You")
                .font(.body.bold())
                .foregroundColor(.white)
        }else{
            let isFollow = userManager.user?.isFollowing(for: user.id) ?? false
            
            ButtonView(label: isFollow ? "Unfollow" : "Follow", type: isFollow ? .secondary : .primary, height: 32, font: .body.bold()) {
                viewModel.followOrUnFollow(isFollower: isFollow, currentUserId: userManager.user?.id, userId: user.id)
            }
            .frame(width: 100)
        }
    }
}


enum FollowTab: String, CaseIterable{
    case followers, following
}
