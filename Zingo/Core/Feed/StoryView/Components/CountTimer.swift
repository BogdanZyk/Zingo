//
//  CountTimer.swift
//  Zingo
//
//  Created by Bogdan Zykov on 31.05.2023.
//

import SwiftUI

import Foundation
import Combine

class CountTimer: ObservableObject{
    
    @Published var progress: Double = .zero
    private var interval: TimeInterval
    private var max: Int
    private let publisher: Timer.TimerPublisher
    private var cancellable: Cancellable?
    
    
    init(max: Int, interval: TimeInterval){
        self.max = max
        self.interval = interval
        self.publisher = Timer.publish(every: 0.1, on: .main, in: .default)
    }
    
    deinit{
        cancellable?.cancel()
    }
    
    func start(){
        self.cancellable = self.publisher.autoconnect()
            .sink(receiveValue: {[weak self] _ in
                guard let self = self else {return}
                
                var newProgress = self.progress + (0.1 / self.interval)
                if Int(newProgress) >= self.max{
                    newProgress = 0
                }
                self.progress = newProgress
        })
    }
    
    
    func advancePage(by number: Int){
        let newProgress = Swift.max((Int(progress) + number) % max, 0)
        self.progress = Double(newProgress)
    }
}
