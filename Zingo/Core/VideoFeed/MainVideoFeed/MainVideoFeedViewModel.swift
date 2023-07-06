//
//  MainVideoFeedViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 27.06.2023.
//

import Foundation


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
}


// Like action
extension MainVideoFeedViewModel{
    
    func likeAction(_ isDidLiked: Bool){
        
    }
    
}
