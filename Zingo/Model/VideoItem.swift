//
//  VideoItem.swift
//  Zingo
//
//  Created by Bogdan Zykov on 14.07.2023.
//

import SwiftUI

struct VideoItem: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            return createVideoItem(received)
        }
        
        FileRepresentation(contentType: .video) { video in
            SentTransferredFile(video.url)
        } importing: { received in
           return createVideoItem(received)
        }
    }
    
    static func createVideoItem(_ received: ReceivedTransferredFile) -> VideoItem{
        let id = UUID().uuidString
        let copyURl = URL.documentsDirectory.appending(path: "\(id).mp4")
        FileManager.default.removeFileIfExists(for: copyURl)
        try? FileManager.default.copyItem(at: received.file, to: copyURl)
        return .init(url: copyURl)
    }
}
