//
//  UploaderVideoFeedManager.swift
//  Zingo
//
//  Created by Bogdan Zykov on 26.06.2023.
//

import Foundation
import FirebaseStorage


class VideoUploaderManager: ObservableObject{
    
    var video: DraftVideo?
    @Published var error: Error?
    @Published private(set) var progress: Double = 0
    @Published private(set) var loadState: LoadState = .empty
    
    private let feedVideoService = FeedVideoService.shared
    private let storage = StorageManager.shared
    private var uploadTask: StorageUploadTask?
    private var user: User?
    
    
    init(user: User?) {
        self.user = user
    }
    
    func setVideo(_ video: DraftVideo){
        self.video = video
        uploadFeedVideo()
    }
    
    var showUploaderView: Bool{
        loadState == .loading || loadState == .pause || loadState == .error
    }
        
   private func uploadFeedVideo(){
        guard loadState != .loading, let video, let user else {return}
        loadState = .loading
        uploadTask = storage.createUploadVideoTask(videoUrl: video.url, for: user.id)
        
        addObservers()
    }
    
    
    private func createVideo(_ path: String){
        
        guard let video, let user else { return }
        
        Task{
            do{
                
                var uploadedThumbImage: StoreImage? = nil
                
                if let image = video.thumbnailImage{
                    uploadedThumbImage = try? await storage.saveImage(image: image, type: .video, userId: user.id)
                }
                
                let fullPath = try await storage.getFullPathUrl(path: path).absoluteString
                
                let storeVideo = StoreVideo(path: path, fullPath: fullPath, thumbImage: uploadedThumbImage)
                
                try await feedVideoService.createFeedVideo(owner: .init(user: user),
                                                           video: storeVideo,
                                                           description: video.description,
                                                           isDisabledComments: video.isDisabledComments,
                                                           isHiddenLikesCount: video.isHiddenLikesCount)
                
                video.removeAllVideo()
                nc.post(name: .successfullyFeedVideo)
                await MainActor.run{
                    loadState = .load
                }
                
            }catch{
                self.error = error
                loadState = .empty
            }
        }
    }
    
    private func addObservers(){
        guard let uploadTask else {return}
        
        uploadTask.observe(.success) { snapshot in
            guard let path = snapshot.metadata?.path else {return}
            self.createVideo(path)
        }
        
        uploadTask.observe(.progress) { snapshot in
            DispatchQueue.main.async {
                self.progress = (Double(snapshot.progress?.completedUnitCount ?? 1) / Double(snapshot.progress?.totalUnitCount ?? 1)) * 100.0
            }
        }
        
        uploadTask.observe(.pause) { _ in
            DispatchQueue.main.async {
                self.loadState = .pause
            }
        }
        
        uploadTask.observe(.resume) { _ in
            DispatchQueue.main.async {
                self.loadState = .loading
            }
        }
        
        uploadTask.observe(.failure) { _ in
            DispatchQueue.main.async {
                self.loadState = .error
            }
        }
    }
    
    func cancel(){
        uploadTask?.cancel()
        loadState = .empty
        video?.removeAllVideo()
    }
    
    func pause(){
        uploadTask?.pause()
    }
    
    func resume(){
        uploadTask?.resume()
    }
    
    func tryAgain(){
        uploadFeedVideo()
    }
    
    enum LoadState: Int{
        case empty, loading, load, pause, error
    }
}
