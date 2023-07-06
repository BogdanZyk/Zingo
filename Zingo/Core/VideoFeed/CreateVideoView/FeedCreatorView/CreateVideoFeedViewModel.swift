//
//  CreateVideoFeedViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 26.06.2023.
//

import Foundation

@MainActor
class CreateVideoFeedViewModel: ObservableObject{
    
    @Published var video: DraftVideo
    @Published var error: Error?
    
    @Published var isDisabledComments = false
    @Published var isHiddenLikesCount = false
    @Published private(set) var loadState: LoadState = .empty
    
    private let feedVideoService = FeedVideoService.shared
    private var loadTack: Task<Void, Never>? = nil
    private var user: User?
    
    
    init(video: DraftVideo) {
        self.video = video
    }
    
    func setUser() async{
        self.user = try? await UserService.share.getCurrentUser()
    }

    func cancel(){
        loadTack?.cancel()
        loadTack = nil
        loadState = .empty
    }
    

    func uploadFeedVideo(){
        guard let user, loadState != .loading else {return}
        loadState = .loading
        loadTack = Task{
            do{
                try await feedVideoService.createFeedVideo(owner: .init(user: user), draftVideo: video, isDisabledComments: isDisabledComments, isHiddenLikesCount: isHiddenLikesCount)
                loadState = .load
                FileManager.default.removeFileIfExists(for: video.url)
                nc.post(name: .successfullyFeedVideo)
            }catch{
                self.error = error
                loadState = .empty
            }
        }
    }
    
    enum LoadState: Int{
        case empty, loading, load
    }
}
