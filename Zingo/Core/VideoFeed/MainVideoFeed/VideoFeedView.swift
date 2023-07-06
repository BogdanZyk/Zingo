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
        ZStack(alignment: .top){
            GeometryReader { proxy in
                let size = proxy.size
                ZStack(alignment: .leading){
                    TabView(selection: $viewModel.currentVideoId) {
                        ForEach(viewModel.videos) { video in
                            FeedVideoCellView(video: video, currentUserId: userManager.user?.id, feedViewModel: viewModel)
                            .frame(width: size.width)
                            .rotationEffect(.degrees(-90))
                            .ignoresSafeArea(.all, edges: .top)
                            .tag(video.id)
                        }
                    }
                    
                }
                .rotationEffect(.degrees(90))
                .frame(width: size.height)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(width: size.width)
            }
            
        }
        .ignoresSafeArea(.all, edges: .top)
        .bottomTabPadding()
        .background(Color.black.ignoresSafeArea())
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            header
        }
        .sheet(isPresented: $viewModel.showComments) {
            VStack{
                
            }
            .allFrame()
            .background(Color.darkBlack)
            .presentationDetents([.fraction(0.9)])
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
                mainRouter.setFullScreen(.feedCameraView)
            } label: {
                Image(systemName: "camera.fill")
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        
    }
}



