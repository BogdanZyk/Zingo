//
//  CommentViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI


@MainActor
class CommentViewModel: ObservableObject {
    
    private let postId: String
    @Published private(set) var currentUser: User?
    @Published private(set) var comments = [Comment]()
    @Published private(set) var updateCounter: Int = 0
    @Published private(set) var lastCommentId: String?
    @Published var commentText: String? = ""
    private let userService = UserService.share
    private let commentService = CommentsService.share
    private var listener = FBListener()
    private var cancelBag = CancelBag()
    
    
    func getCurrentUser() async {
        currentUser = try? await userService.getCurrentUser()
    }
    
    
    init(postId: String){
        self.postId = postId
        startCommentsListener()
    }
    
    deinit{
        listener.cancel()
    }
    
    private func startCommentsListener(){
        let (publisher, listener) = commentService.addCommentsListener(for: postId)
        
        self.listener.listener = listener
        
        publisher.sink { completion in
            switch completion{
                
            case .finished: break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: { comments in
            self.comments = comments
            self.updateCounter += 1
        }
        .store(in: cancelBag)

    }
    
    func sendComment() async{
        guard let currentUser else { return }
        let comment = Comment(id: UUID().uuidString, postId: postId, owner: .init(user: currentUser), text: commentText)
        do{
            commentText = ""
            try await commentService.createComment(for: postId, comment: comment)
            lastCommentId = comment.id
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func likeOrUnLike(comment: Comment) async{
        guard let currentUser else { return }
        do{
            if comment.didLike(currentUser.id){
                try await commentService.unLikeComment(userId: currentUser.id, postId: postId, commentId: comment.id)
            }else{
                try await commentService.likeComment(userId: currentUser.id, postId: postId, commentId: comment.id)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
}


