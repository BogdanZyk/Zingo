//
//  PostView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct PostView: View {
    var post: Post
    var body: some View {
        VStack(spacing: 16){
            VStack(alignment: .leading, spacing: 16){
                userSection
                postContent
                postStats
            }
            .foregroundColor(.white)
            Rectangle()
                .fill(Color.darkGray)
                .frame(height: 1)
                .padding(.horizontal, -16)
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.darkBlack
            PostView(post: Post.mockPosts.last!)
                .padding(.horizontal)
        }
    }
}


extension PostView{
    
    private var userSection: some View{
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
            
            Button {
                
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.lightGray)
            }
        }
    }
    
    
    
    private var postContent: some View{
        Group{
            if let image = post.images.first?.fullPath{
                LazyNukeImage(strUrl: image, resizeHeight: 400, resizingMode: .aspectFill, loadPriority: .high)
                    .frame(height: 180)
                    .cornerRadius(16)
            }
            if let text = post.caption{
                Text(text)
                    .lineLimit(5)
                    .lineSpacing(5)
            }
        }
    }
    
    private var postStats: some View{
        HStack(spacing: 16){
            buttonIcon(.like(post.likes))
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
                break
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
    }
}
