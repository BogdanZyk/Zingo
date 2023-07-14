//
//  VideoEditorPreview.swift
//  Zingo
//
//  Created by Bogdan Zykov on 14.07.2023.
//

import SwiftUI

struct VideoEditorPreview: View {
    @Environment(\.dismiss) private var dismiss
    private let video: DraftVideo
    @State private var recordTime: RecordTime
    @StateObject private var playerManager: VideoPlayerManager
    @State private var newTimeRange: ClosedRange<Double> = 0...6
    @State private var showLoader: Bool = false
    
    let onSave: (DraftVideo) -> Void
    
    init(video: DraftVideo, recordTime: RecordTime, onSave: @escaping (DraftVideo) -> Void) {
        self.video = video
        self._playerManager = StateObject(wrappedValue: VideoPlayerManager(video: video))
        self._recordTime = State(wrappedValue: recordTime)
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack{
            Color.darkBlack.ignoresSafeArea()
            VStack(spacing: 0){
                topBar
                ZStack {
                    PlayerRepresentable(player: playerManager.videoPlayer)
                        .ignoresSafeArea()
                        .onTapGesture {
                            playerManager.action()
                        }
                }
                
                bottomBar
            }
        }
        .onAppear{
            setRange()
        }
    }
}

struct VideoEditorPreview_Previews: PreviewProvider {
    static var previews: some View {
        VideoEditorPreview(video: .mock, recordTime: .full){_ in}
    }
}

extension VideoEditorPreview{
    
    private var topBar: some View{
        HStack{
            IconButton(icon: .arrowLeft){
                dismiss()
            }
            Spacer()
            totalRecordTimeButton
        }
        .padding([.horizontal])
    }
    
    private var bottomBar: some View{
        VStack(spacing: 16){
            VideoTrimBarSlider(videoURL: video.url, videoRange: video.rangeDuration, editedRange: $newTimeRange, currentTime: $playerManager.currentTime, onTapTrim: playerManager.action, seek: playerManager.seek)
            HStack {
                Text("Drag the slider to the desired location")
                    .foregroundColor(.white)
                    .font(.caption)
                Spacer()
                ButtonView(label: "Done", showLoader: showLoader, type: .primary, height: 40, isDisabled: false) {
                    createVideo()
                }
                .frame(width: 100)
            }
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private func setRange(){
        newTimeRange = Int(video.rangeDuration.upperBound) <= recordTime.rawValue ? video.rangeDuration : 0...Double(recordTime.rawValue)
    }
    
    private var totalRecordTimeButton: some View{
        Button {
            recordTime = recordTime == .full ? .half : .full
            setRange()
            
        } label: {
            Text(verbatim: String(recordTime.rawValue))
                .font(.callout.bold())
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.3))
                .clipShape(Circle())
                .padding(10)
        }
    }
    
    private func createVideo(){
        showLoader = true
        Task{
            do{
                let url = try await VideoEditorHelper.share.trimAndRotateVideo(video.url, timeRange: newTimeRange)
                let video = await DraftVideo(url: url, recordsURl: [])
                onSave(video)
                showLoader = false
                dismiss()
                
            }catch{
                print(error.localizedDescription)
                showLoader = false
            }
        }
    }
}
