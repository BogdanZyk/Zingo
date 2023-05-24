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
        VStack(spacing: 0) {
            headerSection
            if viewModel.posts.isEmpty{
                loaderView
            }else{
                ScrollView(.vertical, showsIndicators: false) {
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
        }
        .background(Color.darkBlack)
        .navigationDestination(for: RouterDestination.self) { destination in
            switch destination{
            case .userProfile(let id):
                UserProfile(userId: id)
            case .postDetails(let id):
                Text(id)
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
            Text("Good Morning, \(currentUser?.userName ?? "")")
                .font(.title2.bold())
                .lineLimit(1)
            Spacer()
            IconButton(icon: .letter) {
                
            }
        }
        .foregroundColor(.white)
        .padding([.bottom, .horizontal])
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
        Group{
            ProgressView()
                .tint(.accentPink)
                .padding(.top, 30)
            Spacer()
        }
    }
    
    private func onTapOwner(_ id: String){
        router.navigate(to: .userProfile(id: id))
    }
    
    private func onTapPost(_ id: String){
        router.navigate(to: .postDetails(id: id))
    }
}
