//
//  PostViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import Foundation
import SwiftUI

class PostViewModel: ObservableObject{
    
    
    private let postService = PostService.shared
    private var currentUserId: String?
    @Published var showLikeAnimation: Bool = false
    
    init(currentUserId: String?){
        self.currentUserId = currentUserId
    }
    
    
    @MainActor
    func likeUnLikePost(post: Binding<Post>) async{
        guard let currentUserId else {return}
        do{
            if post.wrappedValue.didLike(currentUserId){
                try await postService.unLikePost(userId: currentUserId, postId: post.id)
                post.likedUserIds.wrappedValue.removeAll(where: {$0 == currentUserId})
            }else{
                withAnimation(.interactiveSpring()){
                    showLikeAnimation.toggle()
                    post.likedUserIds.wrappedValue.append(currentUserId)
                }
                try await postService.likePost(userId: currentUserId, postId: post.id)
                
            }
        }catch{
            print(error.localizedDescription)
        }
    }
}
