//
//  CommentsService.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class CommentsService{
        
    private init(){}

    static let share = CommentsService()
    
    private let postService = PostService.shared
    private let videoFeedService = FeedVideoService.shared

    
    func createComment(for id: String, type: CommentType, comment: Comment) async throws{
        try type.getCommentsCollections(parentId: id)
            .document(comment.id)
            .setData(from: comment, merge: false)
        switch type{
        case .post:
            try await postService.incrementCommentCounter(postId: id)
        case .video:
            try await videoFeedService.incrementCommentCounter(videoId: id)
        }
    }
    
    private func getCommentQuery(for id: String, type: CommentType) -> Query{
        type.getCommentsCollections(parentId: id)
            .order(by: Comment.CodingKeys.createdAt.rawValue, descending: false)
    }
    
    func addCommentsListener(for id: String, type: CommentType) -> FBListenerResult<Comment>{
        getCommentQuery(for: id, type: type)
            .addSnapshotListener(as: Comment.self)
    }
    
 
    func likeComment(userId: String, parentCollectionId: String, type: CommentType, commentId: String) async throws{
        
        let dict: [String: Any] = [
            "likedUserIds": FieldValue.arrayUnion([userId])
        ]
        
        try await type.getCommentDocument(parentId: parentCollectionId, commentId: commentId)
            .updateData(dict)
    }
    
    func unLikeComment(userId: String, parentCollectionId: String, type: CommentType, commentId: String) async throws{
        
        let dict: [String: Any] = [
           "likedUserIds": FieldValue.arrayRemove([userId])
        ]
        try await type.getCommentDocument(parentId: parentCollectionId, commentId: commentId)
            .updateData(dict)
    }
}


extension CommentsService{
    
    enum CommentType{
        
        case post, video
        
        func getCommentsCollections(parentId: String) -> CollectionReference{
            var doc: DocumentReference
            
            switch self{
            case .post:
                doc = PostService.shared.getPostDocumentRef(parentId)
            case .video:
                doc = FeedVideoService.shared.getVideoDocumentRef(parentId)
                   
            }
            return doc.collection(FbConstants.commentsCollectionName)
        }
        
        
        func getCommentDocument(parentId: String, commentId: String) -> DocumentReference{
            
            var doc: DocumentReference
            
            switch self{
            case .post:
                doc = PostService.shared.getPostDocumentRef(parentId)
            case .video:
                doc = FeedVideoService.shared.getVideoDocumentRef(parentId)
                   
            }
            return doc.collection(FbConstants.commentsCollectionName).document(commentId)
        }
    }
    
}


