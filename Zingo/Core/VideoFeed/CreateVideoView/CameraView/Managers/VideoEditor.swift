//
//  VideoEditor.swift
//  Zingo
//
//  Created by Bogdan Zykov on 07.06.2023.
//

import Foundation
import AVFoundation
import UIKit


class VideoEditorHelper{
    
    static let share = VideoEditorHelper()
    
    private init(){}
    
    /// Crop video time for range
    func cropTimeVideo(from url: URL, range: ClosedRange<Double>) async throws -> URL{
        
        let asset = AVAsset(url: url)
        let fileManager = FileManager.default
        
        let outputURL = URL.documentsDirectory.appending(path: "\(UUID().uuidString).mp4")
        fileManager.removeFileIfExists(for: outputURL)
        
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset1280x720) else{
            throw ExporterError.cannotCreateExportSession
        }
        
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        let startTime = CMTime(seconds: range.lowerBound, preferredTimescale: 1000)
        let endTime = CMTime(seconds: range.upperBound, preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exporter.timeRange = timeRange
        
        await exporter.export()
        
        if let error = exporter.error {
            throw error
        } else {
            if let url = exporter.outputURL{
                fileManager.removeFileIfExists(for: url)
                return url
            }
            throw ExporterError.failed
        }
    }
    
    
    
    /// Create video
    /// Merge and render videos
    func createVideo(for urls: [URL]) async throws -> URL {
    
        let composition = AVMutableComposition()
        let fileManager = FileManager.default
        
        print("Merged video urls:", urls)
        
        do{
            try await mergeVideos(to: composition, from: urls)
            ///Remove all olds videos
            urls.forEach { url in
                fileManager.removeFileIfExists(for: url)
            }
        }catch{
            print(error.localizedDescription)
        }
        
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720)
        let exportUrl = URL.documentsDirectory.appending(path: "record.mp4")
        fileManager.removeFileIfExists(for: exportUrl)
        
        exporter?.outputURL = exportUrl
        exporter?.outputFileType = .mp4
        exporter?.shouldOptimizeForNetworkUse = true

        await exporter?.export()

        
        if let error = exporter?.error {
            throw error
        } else {
            if let url = exporter?.outputURL{
                return url
            }
            throw ExporterError.failed
        }
    }
    
    
    
    
    /// Merge videos
    /// Combining multiple videos for a composition
    /// audioEnabled:  Turning on the audio track
    private func mergeVideos(to composition: AVMutableComposition,
                             from urls: [URL]) async throws{
        
        let assets = urls.map({AVAsset(url: $0)})
        
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var lastTime: CMTime = .zero
        
        for asset in assets {
            
            let videoTracks = try await asset.loadTracks(withMediaType: .video)
            let audioTracks = try? await asset.loadTracks(withMediaType: .audio)
            
            let duration = try await asset.load(.duration)

            let timeRange = CMTimeRangeMake(start: .zero, duration: duration)
            
            
            print("duration:", duration.seconds, "lastTime:", lastTime.seconds)
            
            if let audioTracks, !audioTracks.isEmpty, let audioTrack = audioTracks.first,
               let compositionAudioTrack {
                try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: lastTime)
                let audioPreferredTransform = try await audioTrack.load(.preferredTransform)
                compositionAudioTrack.preferredTransform = audioPreferredTransform
            }
            
            guard let videoTrack = videoTracks.first else {return}
            try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: lastTime)
            let videoPreferredTransform = try await videoTrack.load(.preferredTransform)
            compositionVideoTrack?.preferredTransform = videoPreferredTransform
            
            lastTime = CMTimeAdd(lastTime, duration)
        }

        print("TotalTime:", lastTime.seconds)
    }

    
}


enum ExporterError: Error, LocalizedError{
    case cancelled
    case cannotCreateExportSession
    case failed
}
