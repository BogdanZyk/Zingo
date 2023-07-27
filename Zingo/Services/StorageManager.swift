//
//  StorageManager.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

final class StorageManager{
    
    static let shared = StorageManager()
    private init(){}
    
    
    private let storage = Storage.storage().reference()
    
   
    private func userReferences(uid: String) -> StorageReference{
        storage.child("users").child(uid)
    }
    
    func getPath(_ path: String) -> StorageReference{
        Storage.storage().reference(withPath: path)
    }
    
    func saveImage(_ data: Data, type: ImageType, uid: String) async throws -> StoreImage{
        let meta = StorageMetadata()
        meta.contentType = "image/jpg"
        let name = "\(UUID().uuidString).jpg"
        let returnedData = try await type.getRef(uid: uid).child(name).putDataAsync(data, metadata: meta)
        
        guard let path = returnedData.path else {
            throw AppError.custom(errorDescription: "Failed upload image")
        }
        try Task.checkCancellation()
        let fullPath = try await getFullPathUrl(path: path).absoluteString
        
        return .init(path: path, fullPath: fullPath)
    }
        
    func uploadVideo(videoUrl: URL, thumbImage: UIImage?, for uid: String) async throws -> StoreVideo{
        
        var uploadedThumbImage: StoreImage? = nil
        let type: ImageType = .video
        if let thumbImage{
            uploadedThumbImage = try await saveImage(image: thumbImage, type: type, userId: uid)
        }
            
        let meta = StorageMetadata()
        meta.contentType = "video/mp4"
        let name = "\(UUID().uuidString).mp4"
        let ref = type.getRef(uid: uid)
        try Task.checkCancellation()
        let returnedData = try await ref.child(name).putFileAsync(from: videoUrl, metadata: meta)
        
        guard let path = returnedData.path else {
            throw AppError.custom(errorDescription: "Failed upload video")
        }
        let fullPath = try await getFullPathUrl(path: path).absoluteString
    
        return .init(path: path, fullPath: fullPath, thumbImage: uploadedThumbImage)
    }
    
    
    func createUploadVideoTask(videoUrl: URL, for uid: String) -> StorageUploadTask{
    
        let type: ImageType = .video
        let meta = StorageMetadata()
        meta.contentType = "video/mp4"
        let name = "\(UUID().uuidString).mp4"
        let ref = type.getRef(uid: uid)
    
        return ref.child(name).putFile(from: videoUrl, metadata: meta)
    }
    
    
    func downloadFile(from path: String, to localURL: URL) -> StorageDownloadTask{
        return storage.child(path).write(toFile: localURL)
    }
    
    func saveImage(image: UIImage, type: ImageType, userId: String) async throws -> StoreImage{
        let resizeImage = image.aspectFittedToHeight(type.size)
        guard let data = resizeImage.jpegData(compressionQuality: type.quality) else {
            throw AppError.custom(errorDescription: "Failed compression image")
        }
        return try await saveImage(data, type: type, uid: userId)
    }
    
    func getFullPathUrl(path: String) async throws -> URL{
        try await getPath(path).downloadURL()
    }
    
    func deleteAsset(path: String) async throws{
        try await getPath(path).delete()
    }
    
    func saveImages(userId: String, images: [UIImageData], typeImage: ImageType) async throws -> [StoreImage]{
        guard !images.isEmpty else { return [] }
        
        return try await withThrowingTaskGroup(of: StoreImage.self, returning: [StoreImage].self) { [weak self] taskGroup in
            
            guard let self = self else {
                throw AppError.custom(errorDescription: "Not image")
            }
            
            for image in images{
                taskGroup.addTask {
                    guard let uiImage = image.image else {
                        throw AppError.custom(errorDescription: "Not image")
                    }
                    return try await self.saveImage(image: uiImage, type: typeImage, userId: userId)
                }
            }
            return try await taskGroup.reduce(into: [StoreImage]()) { partialResult, name in
                partialResult.append(name)
            }
        }
    }
}

extension StorageManager{
    
    enum ImageType: Int{
        case user, banner, post, message, story, video
        
        func getRef(uid: String) -> StorageReference{
            let storage = StorageManager.shared.storage
            switch self{
            case .user, .banner: return storage.child("users").child(uid)
            case .post: return storage.child("posts").child(uid)
            case .message: return storage.child("messages").child(uid)
            case .story: return storage.child("stories").child(uid)
            case .video: return storage.child("feed_videos").child(uid)
            }
        }
        
        var size: CGFloat{
            switch self{
            case .user: return 100
            case .banner: return 350
            case .post: return 500
            case .message: return 200
            case .story: return 600
            case .video:  return 400
            }
        }
        
        var quality: CGFloat{
            switch self{
            case .user: return 0.8
            case .banner: return 0.95
            case .post: return 0.9
            case .message: return 0.7
            case .story: return 0.95
            case .video: return 0.7
            }
        }
    }
    
}


struct StoreImage: Identifiable, Codable, Hashable{
    let path: String
    let fullPath: String
    
    
    func getData() throws -> [String : Any]{
        try Firestore.Encoder().encode(self)
    }
    
    var id: String{ path }
}

extension StoreImage{
    
    static let mocks: [StoreImage] = [.init(path: "", fullPath: "https://i.etsystatic.com/30097568/r/il/c7f1a0/3513889975/il_570xN.3513889975_lfe4.jpg"),
                                      .init(path: "", fullPath: "https://i.etsystatic.com/30097568/r/il/c7f1a0/3513889975/il_570xN.3513889975_lfe4.jpg")]
    
}


struct StoreVideo: Identifiable, Codable{

    let path: String
    let fullPath: String
    var thumbImage: StoreImage?
    
    var id: String{ path }
    
    
    func getData() throws -> [String : Any]{
        try Firestore.Encoder().encode(self)
    }
}
