//
//  CurrentUserManager.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import Foundation


final class CurrentUserManager: ObservableObject{
    
    @Published private(set) var user: User?
    @Published var imagesData: [UIImageData] = []
    @Published var selectedImageType: ProfileImageType = .avatar
    private var userListener = FBListener()
    private let userService = UserService.share
    private let cancelBag = CancelBag()
    
    
    init(){
        startUserListener()
    }
    
    deinit{
        userListener.cancel()
    }
    
    func startUserListener(){
        guard let id = userService.getFBUserId() else {return}
        
        let (pub, listener) = userService.addUserListener(for: id)
        
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
    
    
    
    func uploadImage() async{
        guard let id = userService.getFBUserId() else {return}
        guard let image = imagesData.first?.image else {return}
        do{
            let storageImage = try await StorageManager.shared.saveImage(image: image,
                                                                         type: selectedImageType == .avatar ? .user : .banner,
                                                                         userId: id)
            await removeImage(selectedImageType)
            try await userService.setImageUrl(for: selectedImageType, userId: id, image: storageImage)
            
            await MainActor.run{
                self.imagesData = []
            }
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func uploadImage(){
        Task{
            await uploadImage()
        }
    }
    
    @MainActor
    func removeImage(_ type: ProfileImageType) async{
        if let bannerPath = user?.bannerImage?.path, type == .banner {
            try? await StorageManager.shared.deleteImage(path: bannerPath)
            user?.bannerImage = nil
        }
        
        if let avatarPath = user?.profileImage?.path, type == .avatar {
            try? await StorageManager.shared.deleteImage(path: avatarPath)
            user?.profileImage = nil
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
    
    var title: String{
        switch self {
        case .avatar: return "Adding a profile image"
        case .banner: return "Adding a banner image"
        }
    }
}
