//
//  PostEditorView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct PostEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showImageConfirm: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var pickerType: ImagePickerType = .photoLib
    @StateObject private var viewModel = CreatePostViewModel()
    var body: some View {
        VStack{
            header
        }
        .allFrame()
        .background(Color.darkBlack)
        .imagePicker(pickerType: pickerType, show: $showPhotoPicker, imagesData: $viewModel.imagesData, selectionLimit: 1)
        .confirmationDialog("", isPresented: $showImageConfirm) {
            Button("Camera") {
                pickerType = .camera
                showPhotoPicker.toggle()
            }
            Button("Photo") {
                pickerType = .photoLib
                showPhotoPicker.toggle()
            }
        }
    }
}

struct PostEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PostEditorView()
    }
}

extension PostEditorView{
    
    private var header: some View{
        HStack{
            Button {
                
            } label: {
                Text("Discard")
                    .font(.footnote.bold())
            }
            Spacer()
            ButtonView(label: "Publish", showLoader: false, type: .primary, height: 30, font: .body) {
            }
            .frame(width: 80)
        }
        
        .padding(.horizontal)
        .overlay {
            Text("Create")
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }
    
}
