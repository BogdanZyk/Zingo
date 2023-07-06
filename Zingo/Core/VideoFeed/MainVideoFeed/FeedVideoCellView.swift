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
    let video: FeedVideo
    var currentUserId: String?
    @ObservedObject var feedViewModel: MainVideoFeedViewModel
    @State var isOpacity: Bool = false
    @State private var time: CMTime = .zero
    @State private var isPlay: Bool = false
    @State private var isShowPlay: Bool = false
    @State var showThumbImage: Bool = false
    var body: some View {
        ZStack{
            
            if let url = URL(string: video.video.fullPath){
                VideoPlayer(url: url, play: $isPlay, time: $time)
                    .onStateChanged(onStateChanged)
                    .onPlayToEndTime({resetVideo(withPlay: true)})
                    .contentMode(.scaleAspectFill)
                    .onTapGesture {
                        isPlay.toggle()
                    }
                    .onDisappear{
                        resetVideo(withPlay: false)
                    }
                    .onAppear{
                        isPlay = true
                    }
            }
            
            if let image = video.video.thumbImage?.fullPath, showThumbImage{
                LazyNukeImage(strUrl: image, resizeHeight: 200, resizingMode: .aspectFill, loadPriority: .high)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            
            videoActionLayer
                .padding(.horizontal)
                .padding(.bottom, 10)
                .foregroundColor(.white)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .opacity(isOpacity ? 0.5 : 1)
            
            Image(systemName: "play.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
                .allowsHitTesting(false)
                .opacity(isShowPlay ? 1 : 0)
        }
        .background(geometryReader)
        .animation(.easeInOut(duration: 0.15), value: isOpacity)
    }
}

struct FeedVideoCellView_Previews: PreviewProvider {
    static var previews: some View {
        FeedVideoCellView(video: .mock, feedViewModel: MainVideoFeedViewModel())
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
            VStack(spacing: 30){
                actionButtons
            }
            .padding(.bottom, 50)
        }
        
    }
    
    
    private var videoInfoSection: some View{
        VStack(alignment: .leading, spacing: 16){
            HStack{
                UserAvatarView(image: video.owner.image, size: .init(width: 30, height: 30))
                Text(video.owner.name)
                    .font(.body.bold())
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
            Text("Video description")
                .font(.callout.weight(.medium))
                .lineLimit(1)
        }
    }
    
    private var actionButtons: some View{
        Group{
            VideoActionButton(type: .like(video.isHiddenLikesCount ? 0 : video.likeCount, video.didLike(currentUserId)), action: {})
            if !video.isDisabledComments{
                VideoActionButton(type: .comment(video.comments)){
                    feedViewModel.openComments()
                }
            }
            VideoActionButton(type: .share, action: {})
            VideoActionButton(type: .more, action: {})
        }
    }
    
    private var geometryReader: some View{
        GeometryReader { proxy -> Color in
            let minY = proxy.frame(in: .global).minY
            DispatchQueue.main.async {
                isOpacity = abs(minY) > 1
                isPlay = -minY < proxy.size.height && minY < 1
            }
            return Color.clear
        }
    }
    private func resetVideo(withPlay: Bool = true){
        time = CMTimeMakeWithSeconds(0.0, preferredTimescale: self.time.timescale)
        isPlay = withPlay
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
}

struct VideoActionButton: View{
    let type: VideoAction
    let action: () -> Void
    var body: some View{
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: type.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: type.size)
                
                if let value = type.value, value > 0{
                    Text("\(value)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
            }
        }
    }
}



enum VideoAction {
    
    case like(Int, Bool), comment(Int), share, more
    
    
    var id: Int{
        switch self {
        case .like: return 0
        case .comment: return 1
        case .share: return 2
        case .more: return 3
        }
    }
    
    var image: String{
        switch self {
        case .like(_, let isLiked): return isLiked ? "heart.fill" : "heart"
        case .comment: return "message"
        case .share: return "paperplane"
        case .more: return "ellipsis"
        }
    }
    
    var value: Int?{
        switch self {
        case .like(let value, _): return value
        case .comment(let value): return value
        case .share, .more: return nil
        }
    }
    
    var size: CGFloat{
        switch self {
        case .like, .comment: return 32
        case .share: return 26
        case .more: return 16
        }
    }
}




