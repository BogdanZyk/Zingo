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
                postsListView
                .padding(.horizontal)
            }
        }
        .bottomTabPadding()
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
            case .dialog(let conversation):
                DialogView(participant: conversation.conversationUser, chatId: conversation.id)
            case .dialogForId(let id):
                DialogView(participantId: id)
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
    
    
    private var postsListView: some View{
        PostsListView(router: router, posts: $viewModel.posts,
                      shouldNextPageLoader: viewModel.shouldNextPageLoader,
                      currentUserId: currentUser?.id ?? "",
                      fetchNextPage: viewModel.fetchPosts)
    }
    
    private var loaderView: some View{
        VStack{
            ProgressView()
                .tint(.accentPink)
                .padding(.top, 30)
            Spacer()
        }
        .allFrame()
        .onAppear{
            viewModel.refetch()
        }
    }
    
    private var pullToRefreshView: some View{
        PullToRefreshView(bg: Color.darkBlack){
           viewModel.refetch()
            //            Haptics.shared.play(.light)
        }
    }
}
