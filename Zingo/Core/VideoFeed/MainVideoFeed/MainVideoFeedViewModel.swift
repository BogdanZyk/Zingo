//
//  MainVideoFeedViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 27.06.2023.
//

import Foundation
import AVFAudio


@MainActor
class MainVideoFeedViewModel: ObservableObject{
    
    @Published private(set) var videos = [FeedVideo]()
    @Published var showComments: Bool = false
    @Published var currentVideoId = ""
    private let feedVideoService = FeedVideoService.shared
    private var lastDoc = FBLastDoc()
    private var totalCountVideo: Int = 0
    private var cancelBag = CancelBag()
    
    init(){
        fetchVideo()
        startVideoPreLoader()
        setupNcPublisher()
        AVAudioSession.sharedInstance().configurePlaybackSession()
    }
    
    
    func openComments(){
        showComments.toggle()
    }
    
    func refetch(){
        totalCountVideo = 0
        lastDoc = FBLastDoc()
        fetchVideo()
    }
    
    private func startVideoPreLoader(){
        $currentVideoId
            .dropFirst()
            .sink { id in
                if id == self.videos.last?.id &&
                    self.totalCountVideo > self.videos.count{
                    self.fetchVideo()
                    print("set VideoPreLoader")
                }
            }
            .store(in: cancelBag)
    }
    
    
    func fetchVideo(){
        print("fetch video")
        Task{
            let (videos, lastDoc) = try await feedVideoService.fetchPaginatedVideos(lastDocument: lastDoc.lastDocument)
            
            let total = try await feedVideoService.getTotalCountVideos()
            
            self.totalCountVideo = total
            
            print("total video", total)
            
            if self.lastDoc.lastDocument == nil{
                self.videos = videos
                self.currentVideoId = videos.first?.id ?? ""
            }else if lastDoc != self.lastDoc.lastDocument{
                self.videos.append(contentsOf: videos)
            }
            self.lastDoc.lastDocument = lastDoc
        }
    }
    
    private func setupNcPublisher(){
        nc.publisher(for: .successfullyFeedVideo)
            .delay(for: 0.5, scheduler: RunLoop.main)
            .sink {[weak self] notification in
                guard let self = self else {return}
                self.refetch()
            }
            .store(in: cancelBag)
    }
    
    
    func updateCommentsCounter(_ count: Int){
        guard let index = videos.firstIndex(where: {$0.id == currentVideoId}) else {return}
        videos[index].comments = count
    }
    
    func removeVideo(_ video: FeedVideo){
        Task{
            await feedVideoService.removeVideo(feedVideo: video)
            await MainActor.run{
                videos.removeAll(where: {$0.id == video.id})
            }
        }
    }
}


// Like action
extension MainVideoFeedViewModel{
    
    func likeAction(_ isDidLiked: Bool, userId: String?){
        guard let userId else { return }
        Task{
            do{
                if isDidLiked{
                    try await feedVideoService.unLikeVideo(userId: userId, videoId: currentVideoId)
                    updateVideoLikes(userId, isRemove: true)
                }else{
                    try await feedVideoService.likeVideo(userId: userId, videoId: currentVideoId)
                    updateVideoLikes(userId, isRemove: false)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateVideoLikes(_ userId: String, isRemove: Bool){
        guard let index = videos.firstIndex(where: {$0.id == currentVideoId}) else {return}
        if isRemove{
            videos[index].likedUserIds.removeAll(where: {$0 == userId})
        }else{
            videos[index].likedUserIds.append(userId)
        }
    }
}
