//
//  StoriesListViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 31.05.2023.
//

import Foundation


class StoriesListViewModel: ObservableObject{
    
    
    @Published private(set) var stories = [Story]()
    private let storyServices = StoryService.shared
    private let cancelBag = CancelBag()
    
    init(){
        fetchStories()
        setupNcPublisher()
    }
    
    func fetchStories(){
        
        Task{
            do{
                let stories = try await storyServices.fetchStories()
                let mergedStories = mergeStories(stories)
                await MainActor.run{
                    self.stories = mergedStories
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func setupNcPublisher(){
        nc.publisher(for: .successfullyStory)
            .sink {[weak self] notification in
                guard let self = self else {return}
                self.fetchStories()
            }
            .store(in: cancelBag)
    }
    
    private func mergeStories(_ stories: [Story]) -> [Story]{
        var mergedDataArray = [Story]()
        
            for data in stories {
                if let index = mergedDataArray.firstIndex(where: {$0.creator.id == data.creator.id}) {
                    mergedDataArray[index].images.append(contentsOf: data.images)
                } else {
                    mergedDataArray.append(data)
                }
            }
        
        return mergedDataArray
    }
}





