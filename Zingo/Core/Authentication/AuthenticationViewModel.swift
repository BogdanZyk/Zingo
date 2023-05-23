//
//  AuthenticationViewModel.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation


@MainActor
final class AuthenticationViewModel: ObservableObject{
    
    private let authManager = AuthenticationManager.share
    
    @Published var email: String = ""
    @Published var pass: String = ""
    @Published var userName: String = ""
    @Published private(set) var showLoader: Bool = false
    @Published var error: Error?
    
    
    var isValidEmail: Bool {
        email.isEmail
    }
    
    var isValidPass: Bool{
        !(pass.isEmpty) && pass.count >= 6
    }
    
    var isValidUserName: Bool{
        !userName.isEmpty
    }
    
    func signIn(){
        showLoader = true
        Task{
            do{
                try await authManager.signInWithEmail(email: email, pass: pass)
                self.showLoader = false
            }catch{
                handleError(error)
            }
        }
    }
    
    func createUser(){
        showLoader = true
        Task{
            do{
                try await authManager.createUser(email: email, pass: pass, name: userName)
                self.showLoader = false
            }catch{
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error){
        self.showLoader = false
        self.error = error
    }
}
