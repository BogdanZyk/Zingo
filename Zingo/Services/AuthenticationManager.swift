//
//  AuthenticationManager.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import Foundation
import FirebaseAuth
//import GoogleSignIn
import Combine


final class AuthenticationManager{
    
    
    private(set) var userSession = PassthroughSubject<FirebaseAuth.User?, Never>()
    
    static let share = AuthenticationManager()
    
    
    private init(){
        self.userSession.send(Auth.auth().currentUser)
    }
    
    func getAuthUser() -> AuthDataResult?{
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return AuthDataResult(user: user)
    }
    
    func signOut() throws{
        do{
            try Auth.auth().signOut()
            self.userSession.send(nil)
        }catch{
            throw error
        }
    }
    
    private func singIn(with credentials: AuthCredential) async throws -> AuthDataResult{
        let result = try await Auth.auth().signIn(with: credentials)
        let authDataResult = AuthDataResult(user: result.user)
        let user = User(id: authDataResult.uid, userName: authDataResult.name ?? "", email: authDataResult.email ?? "")
        try await createUser(user)
        userSession.send(result.user)
        return authDataResult
    }
    
    private func createUser(_ user: User) async throws{
        try await UserService.share.createUserIfNeeded(user: user)
    }
}

////MARK: - Sing in with SSO
//extension AuthenticationManager{
//
//    @discardableResult
//    func signInWithGoogle() async throws -> AuthDataResult{
//        let helper = SignInGoogleHelper()
//        let credentials = try await helper.getSignInAuthCredential()
//        return try await singIn(with: credentials)
//    }
//
//    @discardableResult
//    func signInWithApple() async throws -> AuthDataResult{
//        let helper = SignInAppleHelper()
//        let tokens = try await helper.startSignInAppleFlow()
//
//        return try await self.signInWithAppleCredential(appleIdToken: tokens.idToken,
//                                              rawNonce: tokens.nonce)
//    }
//
//    @discardableResult
//    private func signInWithAppleCredential(appleIdToken: String, rawNonce: String) async throws -> AuthDataResult{
//        let credential = OAuthProvider.credential(
//            withProviderID: "apple.com",
//            idToken: appleIdToken,
//            rawNonce: rawNonce
//        )
//        return try await singIn(with: credential)
//    }
//}


//MARK: - Sign in with email
extension AuthenticationManager{
    
    @discardableResult
    func createUser(email: String, pass: String, name: String) async throws -> AuthDataResult{
        let result = try await Auth.auth().createUser(withEmail: email, password: pass)
        let authDataResult = AuthDataResult(user: result.user)
        try await createUser(.init(id: authDataResult.uid, userName: name, email: email))
        return authDataResult
    }
    
    @discardableResult
    func signInWithEmail(email: String, pass: String) async throws -> AuthDataResult{
        let result = try await Auth.auth().signIn(withEmail: email, password: pass)
        self.userSession.send(result.user)
        return .init(user: result.user)
    }
}

////MARK: - SignIn Anonymously
//extension AuthenticationManager{
//
//    @discardableResult
//    func signInAnonymously() async throws -> AuthDataResult{
//        let result = try await Auth.auth().signInAnonymously()
//        return .init(user: result.user)
//    }
//
//}


struct AuthDataResult{
    let uid: String
    let email: String?
    let name: String?
    let photoUrl: String?
    
    
    init(user: FirebaseAuth.User) {
        self.uid = user.uid
        self.email = user.email
        self.name = user.displayName
        self.photoUrl = user.photoURL?.absoluteString
    }
}


