//
//  VideoFeedView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 05.06.2023.
//

import SwiftUI

struct VideoFeedView: View {
    @ObservedObject var userManager: CurrentUserManager
    @EnvironmentObject var mainRouter: MainRouter
    @StateObject private var viewModel = MainVideoFeedViewModel()
    @StateObject private var uploaderManager: VideoUploaderManager
    
    
    init(userManager: CurrentUserManager){
        self._userManager = ObservedObject(wrappedValue: userManager)
        self._uploaderManager = StateObject(wrappedValue: VideoUploaderManager(user: userManager.user))
    }
    
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
        .navigationDestination(for: RouterDestination.self) { destination in
            switch destination{
            case .userProfile(let id):
                UserProfile(userId: id)
            default:
                EmptyView()
            }
        }
        .overlay(alignment: .top) {
            if uploaderManager.showUploaderView{
                UploaderView(uploader: uploaderManager)
            }
        }
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
                mainRouter.setFullScreen(.feedCameraView(uploaderManager))
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
                isShowCamera: mainRouter.fullScreen?.id == 3,
                isShowComments: viewModel.showComments,
                onTapComment: { viewModel.openComments() },
                onTapLike: { viewModel.likeAction($0, userId: userManager.user?.id) },
                onTapUser: {mainRouter.navigate(to: .userProfile(id: video.owner.id))},
                onRemove: {viewModel.removeVideo($0)})
            
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



