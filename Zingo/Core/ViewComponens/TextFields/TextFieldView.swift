//
//  TextFieldView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct TextFieldView: View {
    @State var isSecure: Bool = false
    var showSecureButton: Bool = false
    var placeholder: String
    @Binding var text: String
    var commit: () -> Void = {}
    var body: some View {
        Group{
            HStack{
                SuperTextField(isSecure: isSecure, placeholder: placeholder, text: $text, commit: commit)
                    .padding(.trailing)
                if showSecureButton{
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .padding(.horizontal)
                    }
                }
            }
        }
        .font(.headline.weight(.medium))
        .foregroundColor(.white)
        .padding(.leading)
        .frame(height: 48)
        .background(Color.darkGray)
        .cornerRadius(20)
    }
}

struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBlack
            VStack {
                TextFieldView(showSecureButton: true, placeholder: "text here", text: .constant(""))
                TextFieldView(showSecureButton: true, placeholder: "text here", text: .constant("test test"))
            }
            .padding()
        }
    }
}



struct SuperTextField: View {
    var isSecure: Bool = false
    var placeholder: String
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.8))
            }
            if isSecure {
            SecureField("", text: $text,  onCommit: commit)
            } else {
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
            }
        }
    }
}
