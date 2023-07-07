//
//  CommentViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI


@MainActor
class CommentViewModel: ObservableObject {
    
    private let parentId: String
    private let type: CommentsService.CommentType
    
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
    
    
    init(parentId: String, type: CommentsService.CommentType){
        self.parentId = parentId
        self.type = type
        startCommentsListener()
    }
    
    deinit{
        listener.cancel()
    }
    
    private func startCommentsListener(){
        let fbListenerResult = commentService.addCommentsListener(for: parentId, type: type)
        
        self.listener.listener = fbListenerResult.listener
        
        fbListenerResult.publisher.sink { completion in
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
        let comment = Comment(id: UUID().uuidString, postId: parentId, owner: .init(user: currentUser), text: commentText?.noSpaceStr())
        do{
            commentText = ""
            try await commentService.createComment(for: parentId, type: type, comment: comment)
            lastCommentId = comment.id
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func likeOrUnLike(comment: Comment) async{
        guard let currentUser else { return }
        do{
            if comment.didLike(currentUser.id){
                try await commentService.unLikeComment(userId: currentUser.id, parentCollectionId: parentId, type: type, commentId: comment.id)
            }else{
                try await commentService.likeComment(userId: currentUser.id, parentCollectionId: parentId, type: type, commentId: comment.id)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
}


