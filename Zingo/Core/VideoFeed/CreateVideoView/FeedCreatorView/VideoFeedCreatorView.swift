//
//  VideoFeedCreatorView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 27.06.2023.
//

import SwiftUI

struct VideoFeedCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainRouter: MainRouter
    @StateObject private var viewModel = CreateVideoFeedViewModel(video: .mock)
    
    private var draftVideo: DraftVideo
    
    init(draftVideo: DraftVideo) {
        self.draftVideo = draftVideo
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            videoDescriptionSection
            Divider()
            settings
            Spacer()
        }
        .padding()
        .allFrame()
        .background(Color.darkBlack)
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            navBarSection
        }
        .handle(error: $viewModel.error)
        .onChange(of: viewModel.loadState) { state in
            if state == .load{
                mainRouter.fullScreen = nil
            }
        }
        .overlay {
            loader
        }
        .navigationBarBackButtonHidden(true)
        .task {
            viewModel.video = draftVideo
            await viewModel.setUser()
        }
    }
}

struct VideoFeedCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        VideoFeedCreatorView( draftVideo: .mock)
            .environmentObject(MainRouter())
    }
}

extension VideoFeedCreatorView{
    
    private var navBarSection: some View{
        Text("New video")
            .foregroundColor(.white)
            .font(.title3.bold())
            .hCenter()
            .overlay(alignment: .leading) {
                HStack{
                    IconButton(icon: .arrowLeft) {
                        viewModel.cancel()
                        dismiss()
                    }
                    .padding(.horizontal)
                    Spacer()
                    Button {
                        viewModel.uploadFeedVideo()
                    } label: {
                        Text("Upload")
                            .font(.headline.bold())
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom)
    }
    
    private var videoDescriptionSection: some View{
        HStack(alignment: .top, spacing: 0){
            Group{
                if let image = viewModel.video.thumbnailImage{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }else{
                    Color.secondary
                }
            }
            .frame(width: 150, height: 200)
            .cornerRadius(10)
            Spacer()

            GrowingTextInputView(text: $viewModel.video.description, isRemoveBtn: true, placeholder: "Add description", isFocused: false, minHeight: 50)
        }
    }

    private var settings: some View{
        Group{
            Toggle(isOn: $viewModel.isDisabledComments){
                Text("Disable comments")
                    .font(.body.bold())
                    .foregroundColor(.white)
            }
            Toggle(isOn: $viewModel.isHiddenLikesCount){
                Text("Hidden likes count")
                    .font(.body.bold())
                    .foregroundColor(.white)
            }
        }
        .tint(Color.accentPink)
    }

    @ViewBuilder
    private var loader: some View{
        if viewModel.loadState == .loading{
            ZStack{
                Color.black.opacity(0.5).ignoresSafeArea()
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.darkGray)
                    VStack(spacing: 25) {
                        Text("Upload video")
                            .bold()
                            .foregroundColor(.white)
                        ProgressView()
                            .tint(.accentPink)
                        Button("Cancel"){
                            viewModel.cancel()
                        }
                    }
                }
                .frame(width: 200, height: 150)
            }
        }
    }
}
