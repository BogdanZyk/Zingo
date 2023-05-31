//
//  StoryEditorView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 30.05.2023.
//

import SwiftUI

struct StoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StoryEditorViewModel
    @State private var showPhotoPicker: Bool = true
    
    init(currentUser: User?){
        _viewModel = StateObject(wrappedValue: StoryEditorViewModel(currentUser))
    }
    
    var body: some View {
        ZStack{
            Color.darkBlack.ignoresSafeArea()
            VStack(spacing: 12){
                if let image = viewModel.selectedImage?.image{
                    Image(uiImage: image)
                        .centerCropped()
                        .cornerRadius(30)
                }else{
                    Button {
                        showPhotoPicker.toggle()
                    } label: {
                        Text("Add image")
                    }
                    
                }
                bottomSection
            }
        }
        .imagePicker(pickerType: .photoLib, show: $showPhotoPicker, imagesData: $viewModel.imagesData, selectionLimit: 10, onDismiss: viewModel.setSelectedImage)
        .overlay(alignment: .topLeading) {
            closeButton
        }
        .preferredColorScheme(.dark)
        .overlay {
            if viewModel.showLoader{
                loaderView
            }
        }
    }
}

struct StoryEditorView_Previews: PreviewProvider {
    static var previews: some View {
        StoryEditorView(currentUser: User.mock)
    }
}

extension StoryEditorView{
    

    private func imagesSection(_ proxy: GeometryProxy) -> some View{
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                ForEach(viewModel.imagesData){image in
                    if let uiImage = image.image{
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: proxy.size.width / 8)
                            .cornerRadius(5)
                            .overlay {
                                if viewModel.selectedImage?.id == image.id{
                                    RoundedRectangle(cornerRadius: 5)
                                        .strokeBorder(Color.white, lineWidth: 2)
                                }
                            }
                            .onTapGesture {
                                viewModel.selectedImage = image
                            }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    
    private var bottomSection: some View{
        GeometryReader { proxy in
            HStack{
                if viewModel.imagesData.count > 1{
                    imagesSection(proxy)
                }
                Spacer()
                if viewModel.selectedImage != nil{
                    ButtonView(label: "Publish", type: .primary) {
                        viewModel.createStory{
                            dismiss()
                        }
                    }
                    .frame(width: proxy.size.width / 3)
                    .padding(.horizontal)
                }
            }
        }
        .frame(height: 80)
    }
    
    private var closeButton: some View{
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Material.ultraThinMaterial)
                .clipShape(Circle())
        }
        .padding()
    }
    
    
    private var loaderView: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.darkGray)
                .frame(width: 150, height: 100)
            VStack {
                Text("Creating a story")
                    .foregroundColor(.white)
                ProgressView()
                    .tint(.white)
            }
        }
        .allFrame()
        .background(Material.ultraThinMaterial.opacity(0.8))
    }
}



extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }
}
