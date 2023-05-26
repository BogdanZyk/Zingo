//
//  SwipeView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 26.05.2023.
//

import SwiftUI

extension View {
    
    func swipeAction(imageName: String = "trash",
                     bgColor: Color = .red,
                     perform action: @escaping () -> Void) -> some View{
        
        self.modifier(Swipe(imageName: imageName, bgColor: bgColor, action: action))
    }
}

struct Swipe: ViewModifier{
    let halfDeletionDistance: CGFloat = 70
    @State private var isSwiped: Bool = false
    @State private var offset: CGFloat = .zero
    var imageName: String
    var bgColor: Color
    let action: () -> Void
    
    func body(content: Content) -> some View {
        
        ZStack{
            bgColor
            HStack{
                Spacer()
                Button {
                    onTap()
                } label: {
                    Image(systemName: imageName)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.trailing)
                }
            }
            content
                .background(Color.darkBlack)
                .contentShape(Rectangle())
                .offset(x: offset)
                .gesture(DragGesture().onChanged(onChange).onEnded(onEnded))
                .animation(.easeInOut(duration: 0.3), value: offset)
                .onDisappear{
                    isSwiped = false
                    offset = .zero
                }
        }
    }
    
    private func onChange(_ value: DragGesture.Value){
        
        
        if value.translation.width < 0{
            if isSwiped{
                offset = value.translation.width - halfDeletionDistance
            }
            else{
                offset = value.translation.width
            }
        }
        
    }
    
    private func onEnded(_ value: DragGesture.Value){
        if value.translation.width < 0{
            if -offset > 50{
                isSwiped = true
                offset = -halfDeletionDistance
            }else{
                isSwiped = false
                offset = .zero
            }
        }else{
            isSwiped = false
            offset = .zero
        }
    }
    
    private func onTap(){
        offset = -1000
        Task{
            try await Task.sleep(for: .milliseconds(300))
            action()
        }
    }
}



