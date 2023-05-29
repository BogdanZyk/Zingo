//
//  PostsListView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 29.05.2023.
//

import SwiftUI
import Algorithms

struct PostsListView: View {
    @ObservedObject var router: MainRouter
    @Binding var posts: [Post]
    var shouldNextPageLoader: (String) -> Bool
    var currentUserId: String
    var fetchNextPage: () -> Void
    var onRemove: ((String) -> Void)? = nil
    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach($posts) { post in
                postCell(post)
                if shouldNextPageLoader(post.id){
                    nextPageLoader
                }
            }
        }
    }
}

struct PostsListView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView{
            PostsListView(router: MainRouter(), posts: .constant(Post.mockPosts), shouldNextPageLoader: {_ in false}, currentUserId: "", fetchNextPage: {}, onRemove: nil)
                .padding(.horizontal)
        }
        .background(Color.darkBlack)
        .environmentObject(MainRouter())
    }
}

extension PostsListView{
    private func postCell(_ post: Binding<Post>) -> some View{
        PostView(
            currentUserId: currentUserId,
            post: post,
            onRemove: onRemove,
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

    private var nextPageLoader: some View{
        ProgressView()
            .onAppear{
                print("fetchNextPage")
                fetchNextPage()
            }
    }

    private func onTapOwner(_ id: String){
        router.navigate(to: .userProfile(id: id))
    }
}


