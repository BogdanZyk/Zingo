//
//  PlayerEditorView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import SwiftUI

struct PlayerEditorView: View {
    @State private var rangeDuration: ClosedRange<Double> = 0...5
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerManager: VideoPlayerManager
    @State var isPresentedCreator: Bool = false
    let video: DraftVideo
    init(video: DraftVideo){
        self.video = video
        self._playerManager = StateObject(wrappedValue: VideoPlayerManager(video: video))
    }
    
    var body: some View {
        ZStack{
            Color.darkBlack.ignoresSafeArea()
            VStack(spacing: 0){
                ZStack {
                    PlayerRepresentable(player: playerManager.videoPlayer)
                        .ignoresSafeArea()
                        .onTapGesture {
                            playerManager.action()
                        }
                    timeSlider
                }
                
                bottomSection
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            playPauseIcon
            
            backButton
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isPresentedCreator) {
            VideoFeedCreatorView(draftVideo: video)
        }
    }
}

struct PlayerEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            PlayerEditorView(video: DraftVideo(url: URL(string: "test")!, originalDuration: 10))
        }
    }
}

extension PlayerEditorView{
    
    
    private var backButton: some View{
        IconButton(icon: .arrowLeft) {
            dismiss()
        }
        .vTop()
        .hLeading()
        .padding()
    }
    
    @ViewBuilder
    private var playPauseIcon: some View{
        if !playerManager.isPlaying{
            Image(systemName: playerManager.isPlaying ? "play.fill" : "pause.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.7))
                .padding(20)
                .background(Material.ultraThinMaterial, in: Circle())
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
            Text(video.originalDuration.humanReadableShortTime())
                .font(.body.weight(.medium))
        } onEditingChanged: { changed in
            print(changed)
            if changed{
                playerManager.scrubState = .scrubStarted
            }
        }
        .foregroundColor(.white)
        .tint(.white)
        .vBottom()
        .padding()
    }
    
    private var bottomSection: some View{
        HStack{
            Spacer()
            ButtonView(label: "Next", showLoader: false, type: .primary, isDisabled: false) {
                isPresentedCreator.toggle()
            }
            .frame(width: 120)
        }
        .padding(.top, 10)
        .padding(.horizontal)
    }
}
