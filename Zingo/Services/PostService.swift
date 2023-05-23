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
    
    
    private func getPostDocumentRef(_ postId: String) -> DocumentReference{
        postCollections.document(postId)
    }
    
    
    private func getPostQuery(for ownerId: String?, limit: Int) -> Query{
        postCollections
            .limitOptionally(to: limit)
            .whereFieldOptionally("owner.id", isEqualTo: ownerId)
            .order(by: Post.CodingKeys.createdAt.rawValue, descending: true)
    }
    
    func fetchPaginatedPosts(userId: String? = nil, lastDocument: DocumentSnapshot) async throws -> ([Post], lastDoc: DocumentSnapshot?){
        try await getPostQuery(for: userId, limit: 10)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }
    
    
    func createPost(owner: Post.Owner, images: [UIImageData], text: String?) async throws{
        
        let storeImages = try await saveImages(userId: owner.id, images: images)
        
        let postId = UUID().uuidString
        let post = Post(id: postId, owner: owner, caption: text, images: storeImages, createdAt: Date.now)
        
        try postCollections.document(postId).setData(from: post, merge: false)
        
    }
    
    
//    let images = try await withThrowingTaskGroup(of: UIImage.self, returning: [UIImage].self) { taskGroup in
//        let photoURLs = try await listPhotoURLs(inGallery: "Amsterdam Holiday")
//        for photoURL in photoURLs {
//            taskGroup.addTask { try await downloadPhoto(url: photoURL) }
//        }
//
//        return try await taskGroup.reduce(into: [UIImage]()) { partialResult, name in
//            partialResult.append(name)
//        }
//    }
    
    
    func saveImages(userId: String, images: [UIImageData]) async throws -> [StoreImage]{
        guard !images.isEmpty else { return [] }
        
        let manager = StorageManager.shared
        
        return try await withThrowingTaskGroup(of: StoreImage.self, returning: [StoreImage].self) { taskGroup in
            for image in images{
                taskGroup.addTask {
                    guard let uiImage = image.image else {
                        throw AppError.custom(errorDescription: "Not image")
                    }
                    return try await manager.saveImage(image: uiImage, type: .post, userId: userId)
                }
            }
            return try await taskGroup.reduce(into: [StoreImage]()) { partialResult, name in
                partialResult.append(name)
            }
        }
    }
    
    func removePost(for id: String) async throws{
       try await getPostDocumentRef(id).delete()
    }
}
