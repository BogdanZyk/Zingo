//
//  LoginView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    var body: some View {
        NavigationStack{
            VStack(spacing: 10){
                Spacer()
                logo
                formView
                forgotPassButton
                submitButton
                Spacer()
                switchLoginButton
            }
            .padding()
            .allFrame()
            .background(Color.darkBlack)
        }
        .disabled(viewModel.showLoader)
        .handle(error: $viewModel.error)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension LoginView{
    
    private var logo: some View{
        
        LinearGradient.primaryGradient
        .mask(
            Text("Zingo")
                .font(Font.system(size: 46, weight: .bold))
        )
        .frame(height: 100)
    }
    
    private var formView: some View{
        
        Group{
            TextFieldView(isSecure: false, showSecureButton: false, placeholder: "Enter your email", text: $viewModel.email, commit: {})
                .textContentType(.emailAddress)
            TextFieldView(isSecure: true, showSecureButton: true, placeholder: "Enter your password", text: $viewModel.pass, commit: {})
                .textContentType(.password)
        }
    }
    
    private var submitButton: some View{
        ButtonView(label: "Log in", showLoader: viewModel.showLoader, type: .primary, font: .title3.bold(), isDisabled: viewModel.isValidEmail && viewModel.isValidPass) {
            viewModel.signIn()
        }
        .padding(.vertical, 20)
    }
    
    private var forgotPassButton: some View{
        Button {
            
        } label: {
            Text("Forgot password?")
                .foregroundColor(.accentPink.opacity(0.7))
        }
        .hTrailing()
    }
    
    private var switchLoginButton: some View{
        NavigationLink {
            CreateUserStepView(authVM: viewModel, viewType: .email)
        } label: {
            Text("Don't have an account?")
                .font(.body)
                .foregroundColor(.accentPink)
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}
