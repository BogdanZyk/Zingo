//
//  FollowingsFollowersViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 01.06.2023.
//

import Foundation


class FollowingsFollowersViewModel: ObservableObject{
    
    
    @Published var followers = [ShortUser]()
    @Published var followings = [ShortUser]()
    private let user: User
    private let userService = UserService.share
    
    init(user: User){
        self.user = user
        fetchFollowers()
        fetchFollowings()
    }

        
    func fetchFollowers(){
        guard !user.followers.isEmpty else {return}
        
        Task{
            let followers = try await fetchUsers(user.followers)
            await MainActor.run{
                self.followers = followers
            }
        }
    }
    
    func fetchFollowings(){
        guard !user.followings.isEmpty else {return}
        
        Task{
            let followings = try await fetchUsers(user.followings)
            await MainActor.run{
                self.followings = followings
            }
        }
    }
    
    func followOrUnFollow(isFollower: Bool, currentUserId: String?, userId: String){
        guard let currentUserId else {return}
        Task{
            do{
                if isFollower{
                    print("unFollowUser")
                    try await userService.unFollowUser(whomId: userId, userId: currentUserId)
                }else{
                    print("followUser")
                    try await userService.followUser(whomId: userId, userId: currentUserId)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
        
    private func fetchUsers(_ userIds: [String]) async throws -> [ShortUser]{
        return try await userService.getUsers(ids: userIds).map({ShortUser(user: $0)})
    }
}
