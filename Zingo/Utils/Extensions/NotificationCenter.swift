//
//  NotificationCenter.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import Foundation
import Combine

let nc: NotificationCenter = .default

extension NotificationCenter {
    
    static var cancellables = Set<AnyCancellable>()
    
    func publisher(
        for name: Notification.Name,
        @_implicitSelfCapture perform: @escaping (Publisher.Output) -> Void
    ) {
        self.publisher(for: name)
            .receive(on: RunLoop.main)
            .sink { notification in
                perform(notification)
            }
            .store(in: &NotificationCenter.cancellables)
    }
    
    func post(name: Notification.Name) {
        self.post(name: name, object: nil)
    }
    
    func publisher(for name: Notification.Name) -> NotificationCenter.Publisher {
        self.publisher(for: name, object: nil)
    }
    
}



extension Notification.Name {
    static let successfullyPost = Self("successfullyPost")
    static let successfullyStory = Self("successfullyStory")
    static let successfullyFeedVideo = Self("successfullyFeedVideo")
}
