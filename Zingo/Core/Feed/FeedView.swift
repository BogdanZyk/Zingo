//
//  FeedView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct FeedView: View {
    var currentUser: User?
    @EnvironmentObject var router: MainRouter
    @StateObject private var viewModel = FeedViewModel()
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if viewModel.posts.isEmpty{
                loaderView
            }else{
                pullToRefreshView
                LazyVStack(spacing: 20) {
                    ForEach($viewModel.posts) { post in
                        postCell(post)
                        if viewModel.shouldNextPageLoader(post.id){
                            ProgressView()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.darkBlack)
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            headerSection
        }
        .navigationDestination(for: RouterDestination.self) { destination in
            switch destination{
            case .userProfile(let id):
                UserProfile(userId: id)
            case .chats:
                ChatView()
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(currentUser: .mock)
            .environmentObject(MainRouter())
    }
}


extension FeedView{
    private var headerSection: some View{
        HStack{
            Text("\(Date().getGreetings()), \(currentUser?.userName ?? "")!")
                .font(.title2.bold())
                .lineLimit(1)
            Spacer()
            IconButton(icon: .letter) {
                router.navigate(to: .chats)
            }
        }
        .foregroundColor(.white)
        .padding([.bottom, .horizontal])
        .background(Color.darkBlack)
    }
    
    
    private func postCell(_ post: Binding<Post>) -> some View{
        PostView(
            currentUserId: currentUser?.id,
            post: post,
            onRemove: viewModel.removePost,
            onTapUser: onTapOwner
        )
    }
    
    private var loaderView: some View{
        VStack{
            ProgressView()
                .tint(.accentPink)
                .padding(.top, 30)
            Spacer()
        }
        .allFrame()
    }
    
    private func onTapOwner(_ id: String){
        router.navigate(to: .userProfile(id: id))
    }
    
    private var pullToRefreshView: some View{
        PullToRefreshView(bg: Color.darkBlack){
            viewModel.refetch()
            //            Haptics.shared.play(.light)
        }
    }
}
