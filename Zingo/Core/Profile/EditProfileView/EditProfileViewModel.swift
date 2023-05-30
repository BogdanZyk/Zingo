//
//  EditProfileViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 30.05.2023.
//

import Foundation


class EditProfileViewModel: ObservableObject{
    
    @Published var userInfo: User.UserInfo
    private let userService = UserService.share
    
    init(currentUser: User) {
        self.userInfo = currentUser.getInfo()
    }
    
    
    func updateUserInfo() async{
        do{
            try await userService.updateUserInfo(userInfo)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func setInfoFromType(_ type: EditProfileView.EditRout, text: String, gender: User.Gender?){
        switch type {
        case .name:
            userInfo.fullName = text
        case .username:
            userInfo.userName = text
        case .bio:
            userInfo.bio = text
        case .gender:
            userInfo.gender = gender ?? .over
        }
    }
}
