//
//  UserService.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Combine

final class UserService{
    
    static let share = UserService()
    
    private init() {}
    
    private let usersCollection = Firestore.firestore().collection("users")
    
    private func userDocument(for id: String) -> DocumentReference{
        usersCollection.document(id)
    }
    
    func getAuthData() -> AuthDataResult?{
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return AuthDataResult(user: user)
    }
    
    func getFBUserId() -> String?{
        Auth.auth().currentUser?.uid
    }
    
    func createUserIfNeeded(user: User) async throws{
        ///check if exists doc
        let doc = try await userDocument(for: user.id).getDocument()
        if !doc.exists{
            try userDocument(for: user.id).setData(from: user, merge: false)
        }
    }
    
    func updateUserInfo(_ info: User.UserInfo) async throws{
        try await userDocument(for: info.id).updateData(info.getDict())
    }
    
    func removeUser(for id: String) async throws{
        try await userDocument(for: id).delete()
    }
    
    func getUser(for id: String) async throws -> User{
        try await userDocument(for: id).getDocument(as: User.self)
    }
    
    
    func getUsers(ids: [String]) async throws -> [User]{
        return try await withThrowingTaskGroup(of: User.self, returning: [User].self) { taskGroup in
            for id in ids{
                taskGroup.addTask { [weak self] in
                    guard let self = self else {
                        throw AppError.custom(errorDescription: "Error in get users")
                    }
                    return try await self.getUser(for: id)
                }
            }
            return try await taskGroup.reduce(into: [User]()) { partialResult, name in
                partialResult.append(name)
            }
        }
    }
    
    func getCurrentUser() async throws -> User?{
        guard let uid = getFBUserId() else {
            throw AppError.auth(type: .noSetCurrentUser)
        }
        return try await getUser(for: uid)
    }
    
    func addUserListener(for id: String) -> (AnyPublisher<User?, Error>, ListenerRegistration){
        userDocument(for: id).addSnapshotListener(as: User.self)
    }
    
    func followUser(whomId: String, userId: String) async throws{
        let dict = [User.CodingKeys.followers.rawValue: FieldValue.arrayUnion([userId])]
        try await userDocument(for: whomId).updateData(dict)
        try await addFollower(whomId: userId, userId: whomId)
    }

    func unFollowUser(whomId: String, userId: String) async throws{
        let dict = [User.CodingKeys.followers.rawValue: FieldValue.arrayRemove([userId])]
        try await userDocument(for: whomId).updateData(dict)
        try await removeFollower(whomId: userId, userId: whomId)
    }
    
    private func addFollower(whomId: String, userId: String) async throws{
        let dict = [User.CodingKeys.followings.rawValue: FieldValue.arrayUnion([userId])]
        try await userDocument(for: whomId).updateData(dict)
    }
    
    private func removeFollower(whomId: String, userId: String) async throws{
        let dict = [User.CodingKeys.followings.rawValue: FieldValue.arrayRemove([userId])]
        try await userDocument(for: whomId).updateData(dict)
    }
}


extension UserService{
    
    
    func setImageUrl(for type: ProfileImageType, userId: String, image: StoreImage) async throws{
        try await userDocument(for: userId).updateData(type.getDict(image))
    }

}


struct FBListener{
    
    var listener: ListenerRegistration?
    
    func cancel(){
        listener?.remove()
    }
    
}
