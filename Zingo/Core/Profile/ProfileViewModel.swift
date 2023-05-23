//
//  ProfileViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation


final class ProfileViewModel: ObservableObject{
    
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
    
    var isCurrentUser: Bool{
        user?.id == userService.getFBUserId()
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
        
    func uploadImage(){
        guard let userId else {return}
        
        Task{
            guard let image = imagesData.first?.image else {return}
            do{
                let storageImage = try await StorageManager.shared.saveImage(image: image, type: .user, userId: userId)
                
                await removeImage(selectedImageType)
                
                try await userService.setImageUrl(for: selectedImageType, userId: userId, image: storageImage)
            }catch{
                print(error.localizedDescription)
            }
            
        }
    }
    
     func removeImage(_ type: ProfileImageType) async{
        
         if let bannerPath = user?.bannerImage?.path, type == .banner {
            try? await StorageManager.shared.deleteImage(path: bannerPath)
        }
        
         if let avatarPath = user?.profileImage?.path, type == .avatar {
            try? await StorageManager.shared.deleteImage(path: avatarPath)
        }
    }
}



enum ProfileImageType: Int{
    case avatar, banner
    
    
    func getDict(_ image: StoreImage) throws -> [String: Any] {
            
        let dataDict = try image.getData()
        switch self {
        case .avatar:
            return [User.CodingKeys.profileImage.rawValue: dataDict]
        case .banner:
            return [User.CodingKeys.bannerImage.rawValue: dataDict]
        }
    }
}


