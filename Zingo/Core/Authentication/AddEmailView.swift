//
//  AddEmailView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct AddEmailView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack{
            Text("Add your email")
                .font(.title2.bold())
            
        }
        .foregroundColor(.white)
        .allFrame()
        .background(Color.darkBlack)
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            IconButton(icon: .arrowLeft) {
                dismiss()
            }
            .padding(.horizontal)
        }
    }
}

struct AddEmailView_Previews: PreviewProvider {
    static var previews: some View {
        AddEmailView()
    }
}
