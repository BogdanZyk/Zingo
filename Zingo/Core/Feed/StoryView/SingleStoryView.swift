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
    let onNext: (String) -> Void
    let onPrevious: (String) -> Void

    
    init(story: Story,
         storyIndex: Binding<Int>,
         onNext: @escaping (String) -> Void,
         onPrevious: @escaping (String) -> Void){
        
        self.story = story
        self._counTimer = StateObject(wrappedValue: CountTimer(max: story.images.count, interval: 18))
        self.onNext = onNext
        self.onPrevious = onPrevious
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
        SingleStoryView(story: .mocks.first!, storyIndex: .constant(0), onNext: {_ in}, onPrevious: {_ in})
    }
}


extension SingleStoryView{
    
    private var headerSectionView: some View{
        VStack(spacing: 12) {
            HStack(spacing: 6){
                ForEach(story.images.indices, id: \.self) {index in
                    let progress = min(max(CGFloat(counTimer.progress) - CGFloat(index), 0.0), 1.0)
                    Group{
                        StoryLoadingBar(progress: progress)
                            .frame(height: 3)
                    }
                }
            }
            
            HStack{
                UserAvatarView(image: story.creator.image, size: .init(width: 40, height: 40))
                HStack {
                    Text(story.creator.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    Text(story.createdAt.toFormatDate())
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .hLeading()
        }
        .padding(.top, 12)
        .padding(.horizontal)
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
            let image = story.images[indexProgress]
            Rectangle()
                .fill(Color.clear)
                .frame(width: proxy.size.width / 5, height: proxy.size.height / 1.3)
                .contentShape(Rectangle())
            
                .onTapGesture {
                    if image.id == story.images.first?.id{
                        onPrevious(story.id)
                    }else{
                        counTimer.advancePage(by: -1)
                    }
                }
            
            Spacer()
            Rectangle()
                .fill(Color.clear)
                .frame(width: proxy.size.width / 5, height: proxy.size.height / 1.3)
                .contentShape(Rectangle())
                .onTapGesture {
                    if image.id == story.images.last?.id{
                        onNext(story.id)
                    }else{
                        counTimer.advancePage(by: 1)
                    }
                }
        }
    }
}
