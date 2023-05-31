//
//  StoryView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 31.05.2023.
//

import SwiftUI

struct StoryView: View {
    @Binding var close: Bool
    let stories: [Story]
    @State private var bgOpacity: Double = 1
    @State private var offsetY: CGSize = .zero
    @GestureState var draggingOffset: CGSize = .zero
    var body: some View {
        ZStack(alignment: .top){
            Color.darkGray.ignoresSafeArea()
                .opacity(bgOpacity)
            GeometryReader { proxy in
                VStack(spacing: 16) {
                    TabView {
                        ForEach(stories) { story in
                            SingleStoryView(story: story)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .overlay(alignment: .topTrailing) {
                        closeButton
                    }
                }
                .offset(y: offsetY.height)
                .frame(height: getRect().height / 1.1, alignment: .center)
                .gesture(DragGesture().updating($draggingOffset, body: { value, outValue, _ in
                    outValue = value.translation
                    onChage(draggingOffset)
                }).onEnded(onEnded))
            }
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView(close: .constant(false), stories: Story.mocks)
    }
}



extension StoryView{
    
//    private func headerSectionView(story: Story) -> some View{
//        HStack(spacing: 6){
//            ForEach(story.images.indices, id: \.self) {index in
//                let progress = min(max(CGFloat(counTimer.progress) - CGFloat(index), 0.0), 1.0)
//                Group{
//                    StoryLoadingBar(progress: progress)
//                        .frame(height: 3)
//                }
//            }
//            Button {
//                closeViewWithAnimation()
//            } label: {
//                Image(systemName: "xmark")
//                    .font(.callout.bold())
//                    .foregroundColor(.white)
//                    .padding(10)
//                    .background(Color.white.opacity(0.3))
//                    .clipShape(Circle())
//            }
//            .padding(.leading, 5)
//        }
//        .padding([.horizontal, .top])
//
//    }
//
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
    
    private var closeButton: some View{
        Button {
            closeViewWithAnimation()
        } label: {
            Image(systemName: "xmark")
                .font(.callout.bold())
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.3))
                .clipShape(Circle())
        }
        .padding(10)
    }
}



//MARK: - Dragg logic
extension StoryView{
    private func onChage(_ value: CGSize){
        let haldHeight = getRect().height / 2
        DispatchQueue.main.async {
            offsetY = value.height > 0 ? value : CGSize()
            let progress = offsetY.height / haldHeight
            withAnimation {
                bgOpacity = Double(1 - (progress < 0 ?  -progress : progress))
            }
        }
        
    }
    private func onEnded(_ value: DragGesture.Value){
        let translation = value.translation.height
        DispatchQueue.main.async {
            if translation < 120{
                withAnimation(.default) {
                    bgOpacity = 1
                    offsetY = .zero
                }
                
            }else{
                closeViewWithAnimation()
            }
        }
    }
    
    
    private func closeViewWithAnimation(){
        withAnimation(.easeIn(duration: 0.15)) {
            bgOpacity = 0
            offsetY.height = getRect().height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            withAnimation(.linear(duration: 0.1)) {
                close.toggle()
            }
        }
    }
}
