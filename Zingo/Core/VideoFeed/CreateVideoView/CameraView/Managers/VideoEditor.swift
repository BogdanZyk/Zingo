//
//  VideoEditor.swift
//  Zingo
//
//  Created by Bogdan Zykov on 07.06.2023.
//

import Foundation
import AVFoundation
import UIKit
import VideoRender

class VideoEditorHelper{
    
    static let share = VideoEditorHelper()
    
    private init(){}
    
    /// Crop video time for range
    func cropTimeVideo(from url: URL, range: ClosedRange<Double>) async throws -> URL{
        
        let startTime = CMTime(seconds: range.lowerBound, preferredTimescale: 1000)
        let endTime = CMTime(seconds: range.upperBound, preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        let outputURL = URL.documentsDirectory.appending(path: "\(UUID().uuidString).mp4")
        
        do{
            let render = try await VideoRender(videoURL: url)
            render.cropTime(timeRange: timeRange)
            let _ = try await render.export(exportURL: outputURL, presetName: .exportPreset1280x720, optimizeForNetworkUse: true, frameRate: .fps30, outputFileType: .mp4)
            FileManager.default.removeFileIfExists(for: url)
            return outputURL
            
        }catch{
            throw error
        }
    }
    
    
    
    /// Create video
    /// Merge and render videos
    func createVideo(for urls: [URL]) async throws -> URL {
    
        do{
            let render = try await VideoRender(videoURLs: urls)
            let outputURL = URL.documentsDirectory.appending(path: "draft_\(Date().ISO8601Format()).mp4")
            render.rotate()
            let _ = try await render.export(exportURL: outputURL, presetName: .exportPreset1280x720, optimizeForNetworkUse: true, frameRate: .fps30, outputFileType: .mp4)
            return outputURL
            
        }catch{
            throw error
        }
    }
}

