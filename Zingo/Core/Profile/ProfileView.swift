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
    var userId: String
    
    init(userId: String){
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }
    
    var isCurrentUser: Bool = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
        .foregroundColor(.white)
        .background(Color.darkBlack)
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            backButton
        }
        .overlay(alignment: .topTrailing) {
            profileActionButton
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userId: "")
    }
}



extension ProfileView{
    
    private var bgImage: some View{
        GeometryReader{ geo -> AnyView in
            AnyView(
                LazyNukeImage(strUrl: "https://i.etsystatic.com/30097568/r/il/c7f1a0/3513889975/il_570xN.3513889975_lfe4.jpg", resizingMode: .aspectFill, loadPriority: .high)
                    .frame(height: geo.height)
                    .offset(y: geo.verticalOffset)
            )
            
        }
        .frame(height: 100)
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
            LazyNukeImage(strUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_KIEkMvsIZEmzG7Og_h3SJ4T3HsE2rqm3_w&usqp=CAU", resizingMode: .aspectFill, loadPriority: .high)
                .frame(width: 138, height: 138)
                .clipShape(Circle())
        }
        .offset(y: 75)
    }
    
    
    private var userInfo: some View{
        VStack(spacing: 10) {
            Text("Alex Tsimikas")
                .font(.title2.bold())
            
            Text("Brooklyn, NY")
                .font(.body)
                .foregroundColor(.lightGray)
            Text("Writer by Profession. Artist by Passion!")
                .font(.body.weight(.medium))
        }
        .foregroundColor(.white)
    }
    
    
    private var followerSection: some View{
        HStack(alignment: .bottom, spacing: 16){
            followerLabel(label: "Followers", value: 234)
            Spacer()
            followerLabel(label: "Following", value: 234)
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
            Text("posts")
        case .stories:
            Text("stories")
        case .liked:
            Text("liked")
        case .tagged:
            Text("tagged")
        }
    }
    
    private var backButton: some View{
        IconButton(icon: .arrowLeft) {
            dismiss()
        }
        .padding(.leading)
    }
    
    private var profileActionButton: some View{
        VStack(spacing: 20){
            IconButton(icon: .letter) {}
            IconButton(icon: .bookmark) {}
        }
        .padding(.trailing)
    }
}

enum ProfileTab: String, CaseIterable{
    case posts, stories, liked, tagged
}
