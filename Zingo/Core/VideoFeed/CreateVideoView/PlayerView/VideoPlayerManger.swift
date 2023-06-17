//
//  VideoPlayerManger.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import Foundation
import Combine
import AVKit
import SwiftUI

/// A class for video management
final class VideoPlayerManager: ObservableObject{
    
    @Published var currentTime: Double = .zero
    @Published private(set) var video: DraftVideo?
    @Published private(set) var isPlaying: Bool = false
    
    var videoPlayer = AVPlayer()
    
    private var rate: Float = 1
    private var cancelBag = CancelBag()
    private var timeObserver: Any?
    private var currentDurationRange: ClosedRange<Double>?
    private var isSeekInProgress: Bool = false
    

    init(video: DraftVideo){
        loadVideo(video)
    }
    
    
    deinit {
        removeTimeObserver()
    }
    
    /// Scrubbing state for seek video time
    var scrubState: PlayerScrubState = .reset {
        didSet {
            switch scrubState {
            case .scrubEnded(let seekTime):
                seek(seekTime)
            default : break
            }
        }
    }
    
    
    /// load storage video object
    private func loadVideo(_ video: DraftVideo){
        self.video = video
        self.videoPlayer = AVPlayer(url: video.url)
        self.currentDurationRange = video.rangeDuration
        self.startControlStatusSubscriptions()
    }
    
    /// Play or pause video
    func action(){
        if isPlaying{
            pause()
        }else{
            play(rate)
        }
    }
    
    /// Play or pause video from range
    func action(_ range: ClosedRange<Double>){
        self.currentDurationRange = range
        if isPlaying{
            pause()
        }else{
            play(rate)
        }
    }
        
    /// Observing the change timeControlStatus
    private func startControlStatusSubscriptions(){
        videoPlayer.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                guard let self = self else {return}
                switch status {
                case .playing:
                    print("playing")
                    self.startTimer()
                    self.isPlaying = true
                case .paused:
                    self.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: cancelBag)
    }
    
    
    func pause(){
        guard isPlaying else {return}
        videoPlayer.pause()
    }
    
    /// Set video volume
    func setVolume(_ value: Float){
        pause()
        videoPlayer.volume = value
    }

    /// Play for rate and durationRange
    private func play(_ rate: Float?){
        
        AVAudioSession.sharedInstance().configurePlaybackSession()
        
        if let currentDurationRange{
            if currentTime >= currentDurationRange.upperBound{
                seek(currentDurationRange.lowerBound)
            }else{
                seek(videoPlayer.currentTime().seconds)
            }
        }
        videoPlayer.play()
        
        if let rate{
            self.rate = rate
            videoPlayer.rate = rate
        }

        if isPlaying{
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { _ in
                self.playerDidFinishPlaying()
            }
        }
    }
     
    /// Seek video time
     func seek(_ seconds: Double){
         if isSeekInProgress{return}
         pause()
         isSeekInProgress = true
         videoPlayer.seek(to: CMTimeMakeWithSeconds(seconds, preferredTimescale: 600), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) {[weak self] isFinished in
             guard let self = self else {return}
             if isFinished{
                 self.isSeekInProgress = false
             }else{
                 self.seek(seconds)
             }
         }
    }
    
    func setRateAndPlay(_ rate: Float){
        videoPlayer.pause()
        play(rate)
    }
    
    /// Start video timer
    private func startTimer() {
        
        let interval = CMTimeMake(value: 1, timescale: 10)
        timeObserver = videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            if self.isPlaying{
                let time = time.seconds
                
                if let currentDurationRange = self.currentDurationRange, time >= currentDurationRange.upperBound{
                    self.pause()
                }

                switch self.scrubState {
                case .reset:
                    self.currentTime = time
                case .scrubEnded:
                    self.scrubState = .reset
                case .scrubStarted:
                    break
                }
            }
        }
    }
    
    /// Did finish action seek to zero
    private func playerDidFinishPlaying() {
        seek(currentDurationRange?.lowerBound ?? 0)
    }
    
    /// Remove all time observers
    private func removeTimeObserver(){
        if let timeObserver = timeObserver {
            videoPlayer.removeTimeObserver(timeObserver)
        }
    }
    
    enum PlayerScrubState{
        case reset
        case scrubStarted
        case scrubEnded(Double)
    }

    
}


//
//extension VideoPlayerManager{
//
//
//    func setFilters(mainFilter: CIFilter?, colorCorrection: ColorCorrection?){
//
//        let filters = Helpers.createFilters(mainFilter: mainFilter, colorCorrection)
//
//        if filters.isEmpty{
//            return
//        }
//        self.pause()
//        DispatchQueue.global(qos: .userInteractive).async {
//            let composition = self.videoPlayer.currentItem?.asset.setFilters(filters)
//            self.videoPlayer.currentItem?.videoComposition = composition
//        }
//    }
//
//    func removeFilter(){
//        pause()
//        videoPlayer.currentItem?.videoComposition = nil
//    }
//}
