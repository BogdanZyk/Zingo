//
//  StoryEditorViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 30.05.2023.
//

import Foundation

class StoryEditorViewModel: ObservableObject{
    
    
    @Published var imagesData = [UIImageData]()
    @Published var selectedImage: UIImageData?
    @Published private(set) var showLoader: Bool = false
    @Published var error: Error?
    private let user: User?
    private let storyService = StoryService.shared
    
    init(_ currentUser: User?){
        user = currentUser
    }
    

    func setSelectedImage(){
        selectedImage = imagesData.first
    }
    
    func createStory(onCreate: @escaping () -> Void){
        guard let user else { return }
        showLoader = true
        Task{
            let images = try await saveImages(for: user.id)
            let story = Story(id: UUID().uuidString,
                              creator: .init(user: user),
                              images: images)
            
            try await storyService.createStory(story: story)
            
            await MainActor.run{
                nc.post(name: .successfullyStory)
                showLoader = false
                onCreate()
            }
        }
    }
    
    private func saveImages(for id: String) async throws -> [StoreImage]{
        try await StorageManager.shared.saveImages(userId: id, images: imagesData, typeImage: .story)
    }
}


