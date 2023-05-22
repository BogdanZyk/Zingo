//
//  PostView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct PostView: View {
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
            PostView()
                .padding(.horizontal)
        }
    }
}


extension PostView{
    
    private var userSection: some View{
        HStack{
            LazyNukeImage(strUrl: "https://i.etsystatic.com/30097568/r/il/c7f1a0/3513889975/il_570xN.3513889975_lfe4.jpg", resizingMode: .aspectFill, loadPriority: .high)
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Jacob Washington")
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text("20m ago")
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
        Text("“If you think you are too small to make a difference, try sleeping with a mosquito.” ~ Dalai Lama")
            .lineSpacing(5)
    }
    
    private var postStats: some View{
        HStack(spacing: 16){
            buttonIcon(.like(340))
            buttonIcon(.comment(123))
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
