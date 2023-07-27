//
//  UploaderVideoFeedManager.swift
//  Zingo
//
//  Created by Bogdan Zykov on 26.06.2023.
//

import Foundation
import FirebaseStorage
import Photos


class VideoFileManager: ObservableObject{
    
    var video: DraftVideo?
    @Published var error: Error?
    @Published private(set) var progress: Double = 0
    @Published private(set) var loadState: LoadState = .empty
    @Published private(set) var downloadState: LoadState = .empty
    
    private let feedVideoService = FeedVideoService.shared
    private let storage = StorageManager.shared
    private var uploadTask: StorageUploadTask?
    private var downloadTask: StorageDownloadTask?
    private var user: User?
    
    private let photoLibrary = PHPhotoLibrary.shared()
    private let fileManager = FileManager.default
    private var downloadVideoFileUrl: URL?
    
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
        
        startUploadObservers()
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
    
    private func startUploadObservers(){
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


//MARK: - Save in lib

extension VideoFileManager{
    
    
    func startDownloadObservers(){
        guard let downloadTask else {return}
        
        downloadTask.observe(.success){ snapshot in
            self.saveVideoToGallery()
        }
//        downloadTask.observe(.progress) { snapshot in
//
//            print( (Double(snapshot.progress?.completedUnitCount ?? 1) / Double(snapshot.progress?.totalUnitCount ?? 1)) * 100.0)
//
//        }
    }
    
    func downloadVideo(videoURL: String) {
        downloadState = .loading
        self.downloadTask?.cancel()
        let localURL = fileManager.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
        downloadVideoFileUrl = localURL
        downloadTask = StorageManager.shared.downloadFile(from: videoURL, to: localURL)
        startDownloadObservers()
    }
    
    private func saveVideoToGallery(){
        guard let downloadVideoFileUrl else { return }
        self.photoLibrary.performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: downloadVideoFileUrl)
        }) { completed, error in
            if completed {
                print("Saved to gallery!")
                self.downloadTask = nil
                DispatchQueue.main.async {
                    self.downloadState = .empty
                }
                self.fileManager.removeFileIfExists(for: downloadVideoFileUrl)
            } else if let error = error {
                print("photoLibrary error", error)
                DispatchQueue.main.async {
                    self.downloadState = .empty
                }
            }
        }
    }
}
