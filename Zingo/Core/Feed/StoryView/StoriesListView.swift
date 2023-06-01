//
//  StoriesListView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 30.05.2023.
//

import SwiftUI

struct StoriesListView: View {
    var currentUser: User?
    @EnvironmentObject private var router: MainRouter
    @StateObject private var viewModel: StoriesListViewModel
    
    init(currentUser: User? = nil) {
        self.currentUser = currentUser
        self._viewModel = StateObject(wrappedValue: StoriesListViewModel(currentUserId: currentUser?.id))
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 12) {
                addStoryButton
                ForEach(viewModel.stories) { story in
                    storyCell(story)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 90)
    }
}

struct StoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBlack
            StoriesListView(currentUser: .mock)
                .environmentObject(MainRouter())
        }
        .preferredColorScheme(.dark)
    }
}

extension StoriesListView{
   
    @ViewBuilder
    private var addStoryButton: some View{
        
        Button {
            router.fullScreen = .createStory(currentUser)
        } label: {
            VStack{
                UserAvatarView(image: currentUser?.profileImage?.fullPath, size:.init(width: 60, height: 60))
                    .overlay {
                        if let userStory = viewModel.userStory{
                            Circle()
                                .strokeBorder(LinearGradient.primaryGradient, lineWidth: 2)
                        }
                    }
                    .onTapGesture {
                        guard let userStory = viewModel.userStory else {return}
                        router.showStory(viewModel.stories, selectedId: userStory.id)
                    }
                
                
                Text("Add story")
                    .foregroundColor(.white)
                    .font(.subheadline.bold())
                    .onTapGesture {
                        router.setFullScreen(.createStory(currentUser))
                    }
            }
        }
    }
    
    private func storyCell(_ story: Story) -> some View{
        UserAvatarView(image: story.creator.image, size:.init(width: 60, height: 60))
            .overlay{
                Circle()
                    .strokeBorder(LinearGradient.primaryGradient, lineWidth: 2)
            }
            .onTapGesture {
                router.showStory(viewModel.stories, selectedId: story.id)
            }
    }
}
