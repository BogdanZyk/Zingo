//
//  PostView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct PostView: View {
    @State private var selectionImage = 0
    @State private var showComments: Bool = false
    @Binding var post: Post
    @StateObject var viewModel: PostViewModel
    
    var currentUserId: String?
    var onRemove: ((String) -> Void)?
    var onTapUser: ((String) -> Void)?
    
    init(currentUserId: String?,
         post: Binding<Post>,
         onRemove: ((String) -> Void)?,
         onTapUser: ((String) -> Void)?){
        
        self.currentUserId = currentUserId
        _post = post
        _viewModel = StateObject(wrappedValue: PostViewModel(currentUserId: currentUserId))
        self.onRemove = onRemove
        self.onTapUser = onTapUser
    }
    var body: some View {
        VStack(spacing: 16){
            VStack(alignment: .leading, spacing: 16){
                userSection
                postContent
                postStats
                textSection
            }
            .foregroundColor(.white)
            divider
        }
        .navigationDestination(isPresented: $showComments) {
            PostCommentView(post: $post)
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.darkBlack
            PostView(currentUserId: "", post: .constant(Post.mockPosts.first!), onRemove: {_ in}, onTapUser: {_ in})
                .padding(.horizontal)
        }
    }
}


extension PostView{
    
    private var userSection: some View{
        HStack {
            HStack{
                Group{
                    if let profileImage = post.owner.image{
                        LazyNukeImage(strUrl: profileImage, resizingMode: .aspectFill, loadPriority: .high)
                    }else{
                        Color.secondary
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.owner.name)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                    Text(post.createdAt.timeAgo())
                        .font(.caption)
                        .foregroundColor(.lightGray)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTapUser?(post.owner.id)
            }
            Button {
                onRemove?(post.id)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.lightGray)
            }
        }
    }
    
    
    
    private var postContent: some View{
        Group{
            if !post.images.isEmpty{
                
                imageCarousel(images: post.images)
                    .padding(.horizontal, -16)
                    .overlay {
                        likeAnimation
                    }
            }
        }
        .onTapGesture(count: 2) {
            Task{
                await viewModel.likeUnLikePost(post: $post)
            }
        }
    }
    
    
    @ViewBuilder
    private var textSection: some View{
        if let text = post.caption{
            Text(text)
                .lineLimit(5)
                .lineSpacing(5)
        }
    }
    
    private var postStats: some View{
        HStack(spacing: 16){
            buttonIcon(.like(post.likeCount))
            buttonIcon(.comment(post.comments))
            Spacer()
            buttonIcon(.save)
        }
        .overlay(alignment: .center) {
            pageControlView(images: post.images)
        }
    }
     
    
    private func buttonIcon(_ stats: PostStats) -> some View{
        Button {
            switch stats {
            case .like:
                Task{
                   await viewModel.likeUnLikePost(post: $post)
                }
            case .comment:
                showComments.toggle()
            case .save:
                break
            }
        } label: {
            HStack(spacing: 5){
                Image(stats.image)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Group{
                    switch stats {
                    case .like(let value):
                        Text(verbatim: String(value))
                    case .comment(let value):
                        Text(verbatim: String(value))
                    case .save:
                        EmptyView()
                    }
                }
                .font(.caption.weight(.medium))
            }
            .foregroundColor(stats.id == 0 && post.didLike(currentUserId) ? .accentPink : .white)
        }
    }
    
    enum PostStats{
        
        case like(Int), comment(Int), save
        
        var image: String{
            switch self{
            case .like: return Icon.like.rawValue
            case .comment: return Icon.bubble.rawValue
            case .save: return Icon.bookmark.rawValue
            }
        }
        
        var id: Int{
            switch self{
            case .like: return 0
            case .comment: return 1
            case .save: return 3
            }
        }
    }
    
    @ViewBuilder
    private var likeAnimation: some View{
        if viewModel.showLikeAnimation{
            Image(Icon.like.rawValue)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 75)
                .foregroundColor(.white)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        withAnimation(.interactiveSpring()){
                            viewModel.showLikeAnimation = false
                        }
                    }
                }
        }
    }
    
    private var divider: some View{
        CustomDivider()
            .padding(.horizontal, -16)
    }
    
    
    private func imageCarousel(images: [StoreImage]) -> some View{
        TabView(selection: $selectionImage) {
            ForEach(images.indices, id: \.self) { index in
                LazyNukeImage(strUrl: images[index].fullPath, resizeHeight: 400, resizingMode: .aspectFill, loadPriority: .high)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: getRect().height / 2.5)
    }
    
    private func pageControlView(images: [StoreImage]) -> some View{
        Group{
            if images.count > 1{
                HStack(spacing: 5){
                    ForEach(images.indices, id: \.self) { index in
                        Circle()
                            .fill(selectionImage == index ? Color.accentPink : .lightGray)
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
    }
}


struct CustomDivider: View{
    
    var body: some View{
        Rectangle()
            .fill(Color.darkGray)
            .frame(height: 1)
    }
}
