//
//  PostService.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class PostService{
    
    
    private init(){}
    static let shared = PostService()
    
    
    private let postCollections = Firestore.firestore().collection("posts")
    
    
    func getPostDocumentRef(_ postId: String) -> DocumentReference{
        postCollections.document(postId)
    }
    
    
    private func getPostQuery(for ownerId: String?, limit: Int?) -> Query{
        postCollections
            .limitOptionally(to: limit)
            .whereFieldOptionally("owner.id", isEqualTo: ownerId)
            .order(by: Post.CodingKeys.createdAt.rawValue, descending: true)
    }
    
    func fetchPaginatedPosts(userId: String? = nil, lastDocument: DocumentSnapshot?) async throws -> ([Post], lastDoc: DocumentSnapshot?){
        try await getPostQuery(for: userId, limit: 10)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }
    
    func createPost(owner: ShortUser, images: [UIImageData], text: String?) async throws{
        
        let storeImages = try await StorageManager.shared.saveImages(userId: owner.id, images: images)
        
        let postId = UUID().uuidString
        let post = Post(id: postId, owner: owner, caption: text, images: storeImages, createdAt: Date.now)
        
        try postCollections.document(postId).setData(from: post, merge: false)
        
    }
    
    func removePost(for id: String) async throws{
       try await getPostDocumentRef(id).delete()
    }
    
    
    func getTotalCountPosts(userId: String? = nil) async throws -> Int{
        let snapshot = try await getPostQuery(for: userId, limit: nil)
            .count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func likePost(userId: String, postId: String) async throws{
        
        let dict: [String: Any] = [
            Post.CodingKeys.likedUserIds.rawValue: FieldValue.arrayUnion([userId])
        ]
        try await getPostDocumentRef(postId).updateData(dict)
    }
    
    func unLikePost(userId: String, postId: String) async throws{
        
        let dict: [String: Any] = [
            Post.CodingKeys.likedUserIds.rawValue: FieldValue.arrayRemove([userId])
        ]
        try await getPostDocumentRef(postId).updateData(dict)
    }
    
    func incrementCommentCounter(postId: String) async throws{
        let dict: [String: Any] = [
            Post.CodingKeys.comments.rawValue: FieldValue.increment(1.0)
        ]
        try await getPostDocumentRef(postId).updateData(dict)
    }
}

