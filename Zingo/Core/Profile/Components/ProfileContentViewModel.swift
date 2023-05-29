//
//  ProfileContentViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 29.05.2023.
//

import Foundation

class ProfileContentViewModel: ObservableObject{
    
    @Published var userPosts = [Post]()
    private let postService = PostService.shared
    private var lastDoc = FBLastDoc()
    private var totalCountPosts: Int = 0
    private var cancelBag = CancelBag()
    private var userId: String
    
    
    init(userId: String){
        self.userId = userId
        fetchPosts()
    }
    
    func shouldNextPageLoader(_ postId: String) -> Bool{
        (userPosts.last?.id == postId) && totalCountPosts > userPosts.count
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
    
    func fetchPosts(){
        Task{
            let (posts, lastDoc) = try await postService.fetchPaginatedPosts(userId: userId, lastDocument: lastDoc.lastDocument)
            await MainActor.run {
                self.lastDoc.lastDocument = lastDoc
                self.userPosts = posts
            }
        }
    }
}
