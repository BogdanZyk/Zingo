//
//  Color.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import SwiftUI

extension Color{
    
    
    static let darkBlack = Color("dark black")
    static let darkGray = Color("dark gray")
    static let lightGray = Color("light gray")
    static let lightWhite = Color("light white")
    static let accentPink = Color("pink")
    static let accentPurple = Color("purple")
    static let primaryBlue = Color("blue")
    
}


extension LinearGradient{
    
    
    static let primaryGradient = LinearGradient(colors: [Color.accentPink, .accentPurple], startPoint: .leading, endPoint: .trailing)
}
