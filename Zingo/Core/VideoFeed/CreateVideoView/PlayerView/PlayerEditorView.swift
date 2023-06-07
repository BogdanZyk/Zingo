//
//  PlayerEditorView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import SwiftUI

struct PlayerEditorView: View {
    @State private var showPlayPauseIcon: Bool = false
    @StateObject private var playerManager = VideoPlayerManager()
    let video: Video
    var body: some View {
        ZStack{
            PlayerRepresentable(player: playerManager.videoPlayer)
                .ignoresSafeArea()
                .onTapGesture {
                    playerManager.action(video)
                    showPlayPauseIcon = true
                }
            
            playPauseIcon
        
            timeSlider
            
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

extension PlayerEditorView{
    
    @ViewBuilder
    private var playPauseIcon: some View{
        if showPlayPauseIcon{
            Image(systemName: playerManager.isPlaying ? "play.fill" : "pause.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .padding(20)
                .background(Material.ultraThinMaterial, in: Circle())
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        withAnimation(.easeIn(duration: 2)) {
                            showPlayPauseIcon = false
                        }
                    }
                }
        }
    }
    
    private var timeSlider: some View{
        
        Slider(value: Binding(get: {
            playerManager.currentTime
        }, set: { newValue in
            playerManager.scrubState = .scrubEnded(newValue)
            playerManager.currentTime = newValue
        }), in: video.rangeDuration, step: 0.1) {
            EmptyView()
        } minimumValueLabel: {
            Text("")
        } maximumValueLabel: {
            Text(video.originalDuration.formatterTimeString())
                .font(.body.weight(.medium))
        } onEditingChanged: { changed in
            print(changed)
            if changed{
                playerManager.scrubState = .scrubStarted
            }
        }
        .foregroundColor(.white)
        .padding()
        .tint(.white)
        .vBottom()
    }
}
