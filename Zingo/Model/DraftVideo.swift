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
    
    var totalDuration: Double{
        rangeDuration.upperBound - rangeDuration.lowerBound
    }
    
    init(url: URL) async{
        let asset = AVAsset(url: url)
        self.url = url
        self.originalDuration = await asset.videoDuration() ?? 1
        self.rangeDuration = 0...originalDuration
        self.thumbnailImage = asset.getImage(0, compressionQuality: 0.5)?.rotated(byDegrees: 90)
    }
    
    
    init(url: URL, originalDuration: Double){
        self.url = url
        self.originalDuration = originalDuration
        self.rangeDuration = 0...originalDuration
    }
    
}


extension DraftVideo{
    
    static let mock = DraftVideo(url: URL(string: "url")!, originalDuration: 10)
}
