//
//  StoryService.swift
//  Zingo
//
//  Created by Bogdan Zykov on 31.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class StoryService{
    
    private init(){}
    
    static let shared = StoryService()
    
    private let storiesCollection = Firestore.firestore().collection("stories")
    
    private func storyDocument(for id: String) -> DocumentReference{
        storiesCollection.document(id)
    }
    
    func createStory(story: Story) async throws{
        try storyDocument(for: story.id).setData(from: story, merge: false)
    }
    
    func removeStory(for id: String) async throws{
        try await storyDocument(for: id).delete()
    }
    
    //TO DO need filters
    func fetchStories() async throws -> [Story]{
        try await storiesCollection.getDocuments(as: Story.self)
    }
}

