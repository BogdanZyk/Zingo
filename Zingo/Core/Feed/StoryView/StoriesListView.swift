//
//  StoriesListView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 30.05.2023.
//

import SwiftUI

struct StoriesListView: View {
    var currentUser: User?
    //@State private var showStory: Body = false
    @EnvironmentObject private var router: MainRouter
    @StateObject private var viewModel = StoriesListViewModel()
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
//        .sheet(isPresented: $showStory) {
//            StoryView(stories: viewModel.stories)
//        }
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
    
    private var addStoryButton: some View{
        Button {
            router.fullScreen = .createStory(currentUser)
        } label: {
            VStack{
                UserAvatarView(image: currentUser?.profileImage?.fullPath, size:.init(width: 60, height: 60))
                Text("Add story")
                    .foregroundColor(.white)
                    .font(.subheadline.bold())
            }
        }
    }
    
    private func storyCell(_ story: Story) -> some View{
        UserAvatarView(image: story.creator.image, size:.init(width: 60, height: 60))
            .overlay{
                Circle()
                    .strokeBorder(LinearGradient.primaryGradient, lineWidth: 2.5)
            }
            .onTapGesture {
                router.showStory(viewModel.stories, selectedId: story.id)
            }
    }
}
