//
//  VideoFeedView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 05.06.2023.
//

import SwiftUI

struct VideoFeedView: View {
    @ObservedObject var userManager: CurrentUserManager
    @StateObject private var viewModel = MainVideoFeedViewModel()
    @EnvironmentObject var mainRouter: MainRouter
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            if viewModel.videos.isEmpty{
                loader
            }else{
                GeometryReader { proxy in
                    TabView(selection: $viewModel.currentVideoId) {
                        videosSection(width:  proxy.size.width)
                    }
                    .rotationEffect(.degrees(90))
                    .frame(width:  proxy.size.height)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(width:  proxy.size.width)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .bottomTabPadding()
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            header
        }
        .sheet(isPresented: $viewModel.showComments) {
            CommentsView(parentId: viewModel.currentVideoId, type: .video, onUpdateCounter: {viewModel.updateCommentsCounter($0)})
            .presentationDetents([.fraction(0.9)])
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct VideoFeedView_Previews: PreviewProvider {
    static var previews: some View {
        VideoFeedView(userManager: CurrentUserManager())
            .environmentObject(MainRouter())
    }
}


extension VideoFeedView{
    
    private var header: some View{
        
        HStack{
            Text("Feed")
                .font(.title2.bold())
            Spacer()
            Button {
                mainRouter.setFullScreen(.feedCameraView)
            } label: {
                Image(systemName: "camera.fill")
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
    }
    
    
    private func videosSection(width: CGFloat) -> some View{
        ForEach(viewModel.videos) { video in
            FeedVideoCellView(
                video: video,
                currentUserId: userManager.user?.id,
                isShowComments: viewModel.showComments,
                onTapComment: { viewModel.openComments() },
                onTapLike: { viewModel.likeAction($0, userId: userManager.user?.id) })
            
            .frame(width: width)
            .rotationEffect(.degrees(-90))
            .ignoresSafeArea(.all, edges: .top)
            .tag(video.id)
        }
    }
    
    private var loader: some View{
        ProgressView()
            .tint(.accentPink)
            .scaleEffect(1.5)
    }
}



