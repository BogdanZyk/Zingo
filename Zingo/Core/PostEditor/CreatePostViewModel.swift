//
//  CreatePostViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation


class CreatePostViewModel: ObservableObject{
    
    
    @Published var imagesData = [UIImageData]()
    @Published var text: String? = ""
    @Published private(set) var showLoader: Bool = false
    @Published var error: Error?
    
    var currentUser: User?
    
    private let userService = UserService.share
    private let postService = PostService.shared
   
    
    init(_ currentUser: User?){
        self.currentUser = currentUser
    }
    
    var isValid: Bool{
        !(text.orEmpty.isEmpty) || !(imagesData.isEmpty)
    }

    func createPost(){
        guard let currentUser else {return}
        showLoader = true
        Task{
            do{
                try await postService.createPost(owner: .init(user: currentUser), images:imagesData, text: text)
                await MainActor.run {
                    self.showLoader = false
                    nc.post(name: .successfullyPost)
                }
            }catch{
                await MainActor.run {
                    self.showLoader = false
                    self.error = error
                }
            }
        }
    }
    
}
