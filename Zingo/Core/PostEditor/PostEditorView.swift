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
        VStack(alignment: .leading, spacing: 16){
            header
            textEditorSection
            imagesSection
            Spacer()
        }
        .allFrame()
        .background(Color.darkBlack)
        .imagePicker(pickerType: pickerType, show: $showPhotoPicker, imagesData: $viewModel.imagesData, selectionLimit: 4)
        .confirmationDialog("Images for the post", isPresented: $showImageConfirm, titleVisibility: .visible) {
            confirmButtons
        }
        .overlay {
            if viewModel.showLoader{
                loaderView
            }
        }
        .handle(error: $viewModel.error)
        .task {
            await viewModel.getCurrentUser()
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
                dismiss()
            } label: {
                Text("Discard")
                    .font(.footnote.bold())
            }
            Spacer()
            ButtonView(label: "Publish", showLoader: false, type: .primary, height: 30, font: .body, isDisabled: !viewModel.isValid) {
                viewModel.createPost()
                if viewModel.error == nil{
                    dismiss()
                }
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
    
    private var textEditorSection: some View{
        HStack(spacing: 5) {
            UserAvatarView(image: viewModel.currentUser?.profileImage?.fullPath, size: .init(width: 40, height: 40))
            GrowingTextInputView(text: $viewModel.text, isRemoveBtn: true, placeholder: "What’s on your mind?", isFocused: false, minHeight: 50)
        }
        .padding(.horizontal)
    }
    
    private var imagesSection: some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                Button {
                    showImageConfirm.toggle()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.darkGray)
                            .frame(width: 100, height: 100)
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                ForEach(viewModel.imagesData) { imageData in
                    if let image = imageData.image{
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.imagesData.removeAll(where: {$0.id == imageData.id})
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollDisabled(viewModel.imagesData.isEmpty)
    }
    
    private var loaderView: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.darkGray)
                .frame(width: 150, height: 100)
            VStack {
                Text("Creating a post")
                    .foregroundColor(.white)
                ProgressView()
                    .tint(.white)
            }
        }
        .allFrame()
        .background(Material.ultraThinMaterial.opacity(0.8))
    }
    
    
    private var confirmButtons: some View{
        Group{
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
