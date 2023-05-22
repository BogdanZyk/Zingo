//
//  CreateUserFlowView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct CreateUserStepView: View {
    @ObservedObject var authVM: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    var viewType: AuthStepEnum = .email
    @State private var showNextView: Bool = false
    private var isValid: Bool{
        checkValid()
    }
    var body: some View {
        VStack(spacing: 16){
            VStack{
                Text(viewType.title)
                if viewType == .complete{
                    Text(authVM.userName)
                }
            }
            .font(.title.bold())
            
            Text(viewType.subtitle)
                .font(.footnote)
                .foregroundColor(.lightGray)
                .padding(.bottom)
            Group{
                switch viewType{
                case .email:
                    TextFieldView(isSecure: false, showSecureButton: false, placeholder: "Enter your email", text: $authVM.email, commit: next)
                        .padding(.bottom, 16)
                        .textContentType(.emailAddress)
                case .password:
                    TextFieldView(isSecure: false, showSecureButton: false, placeholder: "Enter your password", text: $authVM.pass, commit: next)
                        .padding(.bottom, 16)
                        .textContentType(.emailAddress)
                case .username:
                    TextFieldView(isSecure: false, showSecureButton: false, placeholder: "Enter your username", text: $authVM.userName, commit: next)
                        .padding(.bottom, 16)
                        .textContentType(.username)
                case .complete:
                    EmptyView()
                }
            }
            ButtonView(label: viewType == .complete ? "Complete" : "Next", showLoader: authVM.showLoader, type: .primary, isDisabled: !isValid) {
                switch viewType{
                case .email, .password, .username:
                    showNextView.toggle()
                case .complete:
                    authVM.createUser()
                }
            }
        }
        .padding(.horizontal)
        .foregroundColor(.white)
        .allFrame()
        .background(Color.darkBlack)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                IconButton(icon: .arrowLeft) {
                    dismiss()
                }
            }
        }
        .disabled(authVM.showLoader)
        .handle(error: $authVM.error)
        .navigationDestination(isPresented: $showNextView) {
            switch viewType{
            case .email:
                CreateUserStepView(authVM: authVM, viewType: .password)
            case .password:
                CreateUserStepView(authVM: authVM, viewType: .username)
            case .username:
                CreateUserStepView(authVM: authVM, viewType: .complete)
            case .complete: EmptyView()
            }
        }
    }
}

struct CreateUserStepView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserStepView(authVM: AuthenticationViewModel())
    }
}



extension CreateUserStepView{
    enum AuthStepEnum: Int{
        case email, username, password, complete
        
        var title: String{
            switch self {
            case .email: return "Add your email"
            case .username: return "Create username"
            case .password: return "Create password"
            case .complete: return "Welcome to Zingo,"
            }
        }
        
        var subtitle: String{
            switch self {
            case .email: return "You'll use this email to sign in to your account"
            case .username: return "Pick a username for your new account. You can always change it later"
            case .password: return "Your password must be at least 6 characters in length"
            case .complete: return "Tap below to complete registration and start using app"
            }
        }
    }
    
    private func next(){
        if isValid{
            switch viewType{
            case .email, .password, .username:
                showNextView.toggle()
            case .complete:
                authVM.createUser()
            }
        }
    }
    
    private func checkValid() -> Bool{
        switch viewType{
        case .email: return authVM.isValidEmail
        case .username: return authVM.isValidUserName
        case .password: return authVM.isValidPass
        case .complete: return true
        }
    }
}
