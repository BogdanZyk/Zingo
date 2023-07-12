//
//  DraftVideo.swift
//  Zingo
//
//  Created by Bogdan Zykov on 17.06.2023.
//

import Foundation
import UIKit
import AVFoundation

struct DraftVideo{
    
    var url: URL
    let originalDuration: Double
    var rangeDuration: ClosedRange<Double>
    var thumbnailImage: UIImage?
    var rate: Float = 1.0
    var description: String?
    var isDisabledComments = false
    var isHiddenLikesCount = false
    
    var recordsURl: [URL]
    
    var totalDuration: Double{
        rangeDuration.upperBound - rangeDuration.lowerBound
    }
    
    init(url: URL, recordsURl: [URL]) async{
        let asset = AVAsset(url: url)
        self.url = url
        self.originalDuration = await asset.videoDuration() ?? 1
        self.rangeDuration = 0...originalDuration
        self.thumbnailImage = asset.getImage(0, compressionQuality: 0.15)
        self.recordsURl = recordsURl
    }
    
    
    init(url: URL, originalDuration: Double){
        self.url = url
        self.originalDuration = originalDuration
        self.rangeDuration = 0...originalDuration
        self.recordsURl = []
    }
    
}


extension DraftVideo{
    
    static let mock = DraftVideo(url: URL(string: "url")!, originalDuration: 10)
    
    
    func removeAllVideo(){
        let fileManager = FileManager.default
        fileManager.removeFileIfExists(for: url)
        recordsURl.forEach({fileManager.removeFileIfExists(for: $0)})
    }
}
