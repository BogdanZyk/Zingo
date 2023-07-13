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
    
    /// Reached the end time of the video
    private var isReachedEndTime: Bool = false

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
        self.setDidFinishPlayingObserver()
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
        
        if isReachedEndTime{
            seek(currentDurationRange?.lowerBound ?? 0)
            isReachedEndTime = false
        }else{
            seek(currentTime)
        }
        videoPlayer.play()
        
        if let rate{
            self.rate = rate
            videoPlayer.rate = rate
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
                 self.handleReachedEndTime(seconds, withPause: false)
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
                
                self.handleReachedEndTime(time, withPause: true)

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
    private func setDidFinishPlayingObserver(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: .main) { [weak self] _ in
            guard let self = self else {return}
            self.pause()
            self.isReachedEndTime = true
        }
    }
    
    /// Remove all time observers
    private func removeTimeObserver(){
        if let timeObserver = timeObserver {
            videoPlayer.removeTimeObserver(timeObserver)
        }
    }
    
    /// Handle is reached end video time
    private func handleReachedEndTime(_ time: Double, withPause: Bool){
        if time.rounded(toPlaces: 2) >= currentDurationRange?.upperBound ?? 0{
            isReachedEndTime = true
            if withPause{
                pause()
            }
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
