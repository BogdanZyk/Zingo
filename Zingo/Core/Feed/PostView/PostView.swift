//
//  PostView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct PostView: View {
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
            }
            .foregroundColor(.white)
            divider
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.darkBlack
            PostView(currentUserId: "", post: .constant(Post.mockPosts.last!), onRemove: {_ in}, onTapUser: {_ in})
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
                TabView {
                    ForEach(post.images) { image in
                        LazyNukeImage(strUrl: image.fullPath, resizeHeight: 400, resizingMode: .aspectFill, loadPriority: .high)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .overlay {
                                likeAnimation
                            }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 180)
                .padding(.horizontal, -16)
            }
            if let text = post.caption{
                Text(text)
                    .lineLimit(5)
                    .lineSpacing(5)
            }
        }
        .onTapGesture(count: 2) {
            Task{
               await viewModel.likeUnLikePost(post: $post)
            }
        }
    }
    
    private var postStats: some View{
        HStack(spacing: 16){
            buttonIcon(.like(post.likeCount))
            buttonIcon(.comment(post.comments))
            buttonIcon(.share)
            Spacer()
            buttonIcon(.save)
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
                break
            case .share:
                break
            case .save:
                break
            }
        } label: {
            HStack(spacing: 5){
                Image(stats.image)
                    .renderingMode(.template)
                Group{
                    switch stats {
                    case .like(let value):
                        Text(verbatim: String(value))
                    case .comment(let value):
                        Text(verbatim: String(value))
                    case .share:
                        EmptyView()
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
        
        case like(Int), comment(Int), share, save
        
        var image: String{
            switch self{
            case .like: return Icon.like.rawValue
            case .comment: return Icon.bubble.rawValue
            case .share: return Icon.share.rawValue
            case .save: return Icon.bookmark.rawValue
            }
        }
        
        var id: Int{
            switch self{
            case .like: return 0
            case .comment: return 1
            case .share: return 2
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
                .scaledToFill()
                .frame(width: 60, height: 60)
                .foregroundColor(.accentPink)
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
        Rectangle()
            .fill(Color.darkGray)
            .frame(height: 1)
            .padding(.horizontal, -16)
    }
}
