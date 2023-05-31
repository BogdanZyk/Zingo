//
//  SingleStoryView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 31.05.2023.
//

import SwiftUI

struct SingleStoryView: View {
    @StateObject var counTimer: CountTimer
    @State var bgOpacity: Double = 1
    @State private var offsetY: CGSize = .zero
    @GestureState var draggingOffset: CGSize = .zero
    var story: Story
    
    init(story: Story){
        self.story = story
        self._counTimer = StateObject(wrappedValue: CountTimer(max: story.images.count, interval: 18))
    }
    
    var indexProgress: Int{
        Int(counTimer.progress)
    }
    var body: some View {
        
        GeometryReader { proxy in
            VStack(spacing: 16) {
                ZStack(alignment: .top){
                    
                    StoryBodyView(storyImage: story.images[indexProgress])
                    
                    headerSectionView
                    pageButtonsControls(proxy)
                        .vBottom()
                }
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            }
        }
        .onAppear{
            counTimer.start()
        }
    }
}

struct SingleStoryView_Previews: PreviewProvider {
    static var previews: some View {
        SingleStoryView(story: .mocks.first!)
    }
}


extension SingleStoryView{
    
    private var headerSectionView: some View{
        HStack(spacing: 6){
            ForEach(story.images.indices, id: \.self) {index in
                let progress = min(max(CGFloat(counTimer.progress) - CGFloat(index), 0.0), 1.0)
                Group{
                    StoryLoadingBar(progress: progress)
                        .frame(height: 3)
                }
            }
        }
        .padding(.leading)
        .padding(.trailing, 60)
        .padding(.top, 30)
    }
    
//    private var likeButton: some View{
//        Button {
//            isLike.toggle()
//        } label: {
//            Image("like")
//                .renderingMode(.template)
//                .foregroundColor(isLike ? .accentColor : .lightGray)
//                .padding()
//                .background(Color.white.opacity(0.2))
//                .clipShape(Circle())
//        }
//    }
    
    private func pageButtonsControls(_ proxy: GeometryProxy) -> some View{
        HStack{
            Rectangle()
                .fill(Color.clear)
                .frame(width: proxy.size.width / 5, height: proxy.size.height / 1.3)
                .contentShape(Rectangle())
            
                .onTapGesture {
                    counTimer.advancePage(by: -1)
                }
            
            Spacer()
            Rectangle()
                .fill(Color.clear)
                .frame(width: proxy.size.width / 5, height: proxy.size.height / 1.3)
                .contentShape(Rectangle())
                .onTapGesture {
                    counTimer.advancePage(by: 1)
                }
        }
    }
}
