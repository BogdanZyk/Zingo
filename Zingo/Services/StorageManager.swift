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
    
    func getPathForImage(_ path: String) -> StorageReference{
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
        let fullPath = try await getUrlForImage(path: path).absoluteString
        
        return .init(path: path, fullPath: fullPath)
    }
    
    func saveImage(image: UIImage, type: ImageType, userId: String) async throws -> StoreImage{
        let resizeImage = image.aspectFittedToHeight(type.size)
        guard let data = resizeImage.jpegData(compressionQuality: type.quality) else {
            throw AppError.custom(errorDescription: "Failed compression image")
        }
        return try await saveImage(data, type: type, uid: userId)
    }
    
    func getUrlForImage(path: String) async throws -> URL{
        try await getPathForImage(path).downloadURL()
    }
    
    func deleteImage(path: String) async throws{
        print(getPathForImage(path))
        try await getPathForImage(path).delete()
    }
}

extension StorageManager{
    
    enum ImageType: Int{
        case user, post, message
        
        func getRef(uid: String) -> StorageReference{
            let storage = StorageManager.shared.storage
            switch self{
            case .user: return storage.child("users").child(uid)
            case .post: return storage.child("posts").child(uid)
            case .message: return storage.child("messages").child(uid)
            }
        }
        
        var size: CGFloat{
            switch self{
            case .user: return 100
            case .post: return 250
            case .message: return 200
            }
        }
        
        var quality: CGFloat{
            switch self{
            case .user: return 0.8
            case .post: return 0.9
            case .message: return 0.7
            }
        }
    }
    
}


struct StoreImage: Codable{
    let path: String
    let fullPath: String
    
    
    func getData() throws -> [String : Any]{
        try Firestore.Encoder().encode(self)
    }
}

