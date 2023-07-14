//
//  FeedVideoCellView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 26.06.2023.
//

import AVFoundation
import SwiftUI
import VideoPlayer

struct FeedVideoCellView: View {
    var video: FeedVideo
    var currentUserId: String?
    @State var isOpacity: Bool = false
    @State private var time: CMTime = .zero
    @State private var isPlay: Bool = false
    @State private var isShowPlay: Bool = false
    @State private var isDisappear: Bool = false
    @State var showThumbImage: Bool = false
    
    var isShowCamera: Bool
    var isShowComments: Bool = false
    let onTapComment: () -> Void
    let onTapLike: (_ isLiked: Bool) -> Void
    let onTapUser: () -> Void
    let onRemove: (FeedVideo) -> Void
    
    var body: some View {
        ZStack{
            
            if let url = URL(string: video.video.fullPath){
                VideoPlayer(url: url, play: $isPlay, time: $time)
                    .autoReplay(true)
                    .onStateChanged(onStateChanged)
                    .contentMode(.scaleAspectFill)
                    .onTapGesture {
                        isPlay.toggle()
                        isShowPlay.toggle()
                    }
                    .onDisappear(perform: resetAndStopVideo)
                    .onAppear(perform: onAppear)
            }
            
           if let image = video.video.thumbImage?.fullPath, showThumbImage{
            LazyNukeImage(strUrl: image, resizeHeight: 200, resizingMode: .aspectFill, loadPriority: .high)
                    .allowsHitTesting(false)
            }
            
            videoActionLayer
                .padding(.horizontal)
                .padding(.bottom, 10)
                .foregroundColor(.white)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .opacity(isOpacity ? 0.5 : 1)
            if isShowPlay{
                Image(systemName: "play.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .allowsHitTesting(false)
            }
        }
        .background(geometryReader)
        .animation(.easeInOut(duration: 0.15), value: isOpacity)
    }
}

struct FeedVideoCellView_Previews: PreviewProvider {
    static var previews: some View {
        FeedVideoCellView(video: .mock, isShowCamera: false, onTapComment: {}, onTapLike: {_ in}, onTapUser: {}, onRemove: {_ in})
            .preferredColorScheme(.dark)
    }
}

extension FeedVideoCellView{
    
    
    private var videoActionLayer: some View{
        
        HStack(alignment: .bottom, spacing: 0){
            VStack{
                videoInfoSection
            }
            Spacer()
            VStack(spacing: 25){
                actionButtons
            }
            .padding(.bottom, 50)
        }
        
    }
    
    
    private var videoInfoSection: some View{
        VStack(alignment: .leading, spacing: 16){
            HStack{
                Group {
                    UserAvatarView(image: video.owner.image, size: .init(width: 30, height: 30))
                    Text(video.owner.name)
                        .font(.body.bold())
                }
                .onTapGesture {
                    onTapUser()
                }
                
                Button {
                    
                } label: {
                    Text("Follow")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 4)
                        .background{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.white.opacity(0.5))
                        }
                }
            }
            Text(video.description ?? "")
                .font(.callout.weight(.medium))
                .lineLimit(1)
        }
    }
    
    private var actionButtons: some View{
        Group{
            let didLike = video.didLike(currentUserId)
            VideoActionButton(type: .like(video.isHiddenLikesCount ? 0 : video.likeCount, didLike), action: { onTapLike(didLike) })
            VideoActionButton(type: .comment(video.comments), action: onTapComment, isBlock: video.isDisabledComments)
            VideoActionButton(type: .share, action: {})
            
            Menu {
                menuButtons
            } label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16)
                    .padding(.vertical, 10)
            }
        }
    }
    
    private var geometryReader: some View{
        GeometryReader { proxy -> Color in
            let minY = proxy.frame(in: .global).minY
            DispatchQueue.main.async {
                isOpacity = abs(minY) > 1
                
                isPlay = -minY < proxy.size.height && minY < 1 && !isShowComments && !isDisappear && !isShowPlay && !isShowCamera
            }
            return Color.clear
        }
    }
    private func resetAndStopVideo(){
        time = CMTimeMakeWithSeconds(0.0, preferredTimescale: self.time.timescale)
        isPlay = false
        isDisappear = true
    }
    
    private func onAppear(){
        isPlay = true
        isDisappear = false
        isShowPlay = false
    }
    
    private func onStateChanged(_ state: VideoPlayer.State){
        switch state {
        case .loading, .error:
            showThumbImage = true
        case .paused(let playProgress, _):
            showThumbImage = playProgress == 0
        case .playing:
            showThumbImage = false
        }
    }
    
    private var menuButtons: some View{
        Group{
            
            Button {
               
            } label: {
                Label("Share", systemImage: "arrowshape.turn.up.right.fill")
            }

            Button {
                onTapUser()
            } label: {
                Label(video.owner.name, systemImage: "person.fill")
            }
            
            if currentUserId == video.owner.id{
                Button(role: .destructive) {
                    onRemove(video)
                } label: {
                    Label("Remove", systemImage: "trash.fill")
                }
            }
        }
    }
}

struct VideoActionButton: View{
    let type: VideoAction
    let action: () -> Void
    var isBlock: Bool = false
    var body: some View{
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: type.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: type.size)
                
                Group{
                    if isBlock{
                        Text("Block")
                    }else{
                        if let value = type.value, value > 0{
                            Text("\(value)")
                        }
                    }
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
            }
        }
        .opacity(isBlock ? 0.5 : 1)
        .disabled(isBlock)
    }
}



enum VideoAction {
    
    case like(Int, Bool), comment(Int), share
    
    
    var id: Int{
        switch self {
        case .like: return 0
        case .comment: return 1
        case .share: return 2
        }
    }
    
    var image: String{
        switch self {
        case .like(_, let isLiked): return isLiked ? "heart.fill" : "heart"
        case .comment: return "message"
        case .share: return "paperplane"
        }
    }
    
    var value: Int?{
        switch self {
        case .like(let value, _): return value
        case .comment(let value): return value
        case .share: return nil
        }
    }
    
    var size: CGFloat{
        switch self {
        case .like, .comment: return 32
        case .share: return 26
        }
    }
}




