//
//  FeedViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import Foundation

class FeedViewModel: ObservableObject{
    
    @Published var posts = [Post]()
    private let postService = PostService.shared
    private var lastDoc = FBLastDoc()
    private var totalCountPosts: Int = 0
    private var cancelBag = CancelBag()
    
    func shouldNextPageLoader(_ postId: String) -> Bool{
        (posts.last?.id == postId) && totalCountPosts > posts.count
    }
    
    init(){
        fetchCountPosts()
        fetchPosts()
        setupNcPublisher()
    }
    
    
    func fetchPosts(){
        Task{
            let (posts, lastDoc) = try await postService.fetchPaginatedPosts(lastDocument: lastDoc.lastDocument)
            await MainActor.run {
                self.lastDoc.lastDocument = lastDoc
                self.posts = posts
            }
        }
    }
    
    func refetch(){
        totalCountPosts = 0
        lastDoc = FBLastDoc()
        fetchCountPosts()
        fetchPosts()
    }
    
    func removePost(_ post: Post){
        Task{
            try await postService.removePost(for: post.id)
            await MainActor.run {
                posts.removeAll(where:{$0.id == post.id})
                totalCountPosts -= 1
            }
        }
    }
    
    private func fetchCountPosts(){
        Task{
            let total = try await postService.getTotalCountPosts()
            await MainActor.run {
                print("total posts", total)
                self.totalCountPosts = total
            }
        }
    }
    
    
    private func setupNcPublisher(){
        nc.publisher(for: .successfullyPost)
            .delay(for: 0.5, scheduler: RunLoop.main)
            .sink {[weak self] notification in
                guard let self = self else {return}
                self.refetch()
            }
            .store(in: cancelBag)
    }
    
    
}

