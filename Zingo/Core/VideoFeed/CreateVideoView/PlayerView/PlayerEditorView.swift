//
//  PlayerEditorView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import SwiftUI

struct PlayerEditorView: View {
    @StateObject private var playerManager = VideoPlayerManager()
    let video: Video
    var body: some View {
        ZStack(alignment: .bottom){
            PlayerRepresentable(player: playerManager.videoPlayer)
                .ignoresSafeArea()
                .onTapGesture {
                    playerManager.action(video)
                }
            
            Slider(value: $playerManager.currentTime, in: video.rangeDuration) { scrubStarted in
              
                    playerManager.scrubState = .scrubEnded(playerManager.currentTime)
                
            }
            .padding()
        }
        .onAppear{
            playerManager.setVideo(video.url)
        }
    }
}

struct PlayerEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerEditorView(video: Video(url: URL(string: "test")!, originalDuration: 10))
    }
}
