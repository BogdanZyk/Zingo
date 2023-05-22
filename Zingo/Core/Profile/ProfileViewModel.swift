//
//  ProfileViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation


final class ProfileViewModel: ObservableObject{
    
    
    private let userId: String
    
    init(userId: String){
        self.userId = userId
    }
    
}
