//
//  UserViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import Foundation

final class UserViewModel: ObservableObject{
    
    @Published var imagesData: [UIImageData] = []
    @Published var selectedImageType: ProfileImageType = .avatar
    @Published private(set) var user: User?
    
    private var userListener = FBListener()
    private let userService = UserService.share
    private let userId: String?
    private let cancelBag = CancelBag()
    
    init(userId: String?){
        self.userId = userId
        startUserListener()
    }
    
    
    deinit{
        userListener.cancel()
    }
    
    var currentUserId: String?{
        userService.getFBUserId()
    }
    
    func startUserListener(){
        guard let userId else {return}
        
        let (pub, listener) = userService.addUserListener(for: userId)
        
        self.userListener.listener = listener
        
        pub
            .sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] user in
                guard let self = self else {return}
                self.user = user
            }
            .store(in: cancelBag)
    }
    
    
    

    func followOrUnFollow(isFollower: Bool){
        guard let currentUserId, let whomId = user?.id else {return}
        Task{
            do{
                if isFollower{
                    try await userService.unFollowUser(whomId: whomId, userId: currentUserId)
                }else{
                    try await userService.followUser(whomId: whomId, userId: currentUserId)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
