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
    

    private func commentsCollections(postId: String) -> CollectionReference{
        postService.getPostDocumentRef(postId).collection("comments")
    }
    
    private func getCommentDocument(postId: String, commentId: String) -> DocumentReference{
        postService.getPostDocumentRef(postId).collection("comments").document(commentId)
    }
    
    func createComment(for id: String, comment: Comment) async throws{
        try commentsCollections(postId: id).document(comment.id).setData(from: comment, merge: false)
        try await postService.incrementCommentCounter(postId: id)
    }
    
    private func getCommentQuery(for id: String) -> Query{
        commentsCollections(postId: id)
            .order(by: Comment.CodingKeys.createdAt.rawValue, descending: false)
    }
    
    func addCommentsListener(for id: String) -> (AnyPublisher<[Comment], Error>, ListenerRegistration){
        getCommentQuery(for: id)
            .addSnapshotListener(as: Comment.self)
    }
    
    
    func likeComment(userId: String, postId: String, commentId: String) async throws{
        
        let dict: [String: Any] = [
            Post.CodingKeys.likedUserIds.rawValue: FieldValue.arrayUnion([userId])
        ]
        try await getCommentDocument(postId: postId, commentId: commentId).updateData(dict)
    }
    
    func unLikeComment(userId: String, postId: String, commentId: String) async throws{
        
        let dict: [String: Any] = [
            Post.CodingKeys.likedUserIds.rawValue: FieldValue.arrayRemove([userId])
        ]
        try await getCommentDocument(postId: postId, commentId: commentId).updateData(dict)
    }
}


