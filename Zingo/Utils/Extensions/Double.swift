//
//  Double.swift
//  Zingo
//
//  Created by Bogdan Zykov on 07.06.2023.
//

import Foundation

extension Double{
    func toTimeWithMilliseconds() -> String{
        let minutes = Int(self / 60)
          let seconds = Int(self.truncatingRemainder(dividingBy: 60))
          let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 10)
          return "\(minutes):\(String(format: "%02d", seconds)).\(milliseconds)"
    }
    
    func formatterTimeString() -> String{
        let minutes = Int(self / 60)
          let seconds = Int(self.truncatingRemainder(dividingBy: 60))
          return "\(minutes):\(String(format: "%02d", seconds))"
    }
}
