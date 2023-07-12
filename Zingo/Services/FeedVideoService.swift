//
//  FeedVideoService.swift
//  Zingo
//
//  Created by Bogdan Zykov on 26.06.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class FeedVideoService{
    
    private init(){}
    static let shared = FeedVideoService()
 
    
    private let videoCollections = Firestore.firestore().collection("feed_videos")
    
    
    func getVideoDocumentRef(_ videoId: String) -> DocumentReference{
        videoCollections.document(videoId)
    }
    
    private func getVideoQuery(limit: Int?) -> Query{
        videoCollections
            .limitOptionally(to: limit)
            .order(by:FeedVideo.CodingKeys.createdAt.rawValue, descending: true)
    }
    
    func fetchPaginatedVideos(userId: String? = nil, lastDocument: DocumentSnapshot?) async throws -> ([FeedVideo], lastDoc: DocumentSnapshot?){
        try await getVideoQuery(limit: 10)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: FeedVideo.self)
    }
    
    func getTotalCountVideos(userId: String? = nil) async throws -> Int{
        let snapshot = try await getVideoQuery(limit: nil)
            .count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func createFeedVideo(owner: ShortUser, video: StoreVideo,
                         description: String?,
                         isDisabledComments: Bool,
                         isHiddenLikesCount: Bool) async throws{
        
        let feedVideo = FeedVideo(owner: owner,
                                  video: video,
                                  description: description ?? "",
                                  isDisabledComments: isDisabledComments,
                                  isHiddenLikesCount: isHiddenLikesCount)
        
        try videoCollections.document(feedVideo.id).setData(from: feedVideo, merge: false)
            
    }
    
    func removeVideo(feedVideo: FeedVideo) async{
        do{
            try await getVideoDocumentRef(feedVideo.id).delete()
            try await StorageManager.shared.deleteAsset(path: feedVideo.video.path)
            if let thumbImagePath = feedVideo.video.thumbImage?.path{
                try await StorageManager.shared.deleteAsset(path: thumbImagePath)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    func likeVideo(userId: String, videoId: String) async throws{
        
        let dict: [String: Any] = [
            FeedVideo.CodingKeys.likedUserIds.rawValue: FieldValue.arrayUnion([userId])
        ]
        try await getVideoDocumentRef(videoId).updateData(dict)
    }
    
    func unLikeVideo(userId: String, videoId: String) async throws{
        
        let dict: [String: Any] = [
            FeedVideo.CodingKeys.likedUserIds.rawValue: FieldValue.arrayRemove([userId])
        ]
        try await getVideoDocumentRef(videoId).updateData(dict)
    }
    
    func incrementCommentCounter(videoId: String) async throws{
        let dict: [String: Any] = [
            FeedVideo.CodingKeys.comments.rawValue: FieldValue.increment(1.0)
        ]
        try await getVideoDocumentRef(videoId).updateData(dict)
    }
}
