//
//  StoryBodyView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 31.05.2023.
//

import SwiftUI

struct StoryBodyView: View {
    var storyImage: StoreImage
    var isDisabled: Bool = false
    var body: some View {
        GeometryReader { proxy in
            ZStack{
                Color.darkBlack
//                if let color = model.image.bgColor{
//                    Color(hex: color)
//                }
                
                LazyNukeImage(strUrl: storyImage.fullPath, resizeHeight: 600, resizingMode: .aspectFill, loadPriority: .veryHigh)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .disabled(isDisabled)
        }
        .clipped()
    }
    
}

struct StoryBodyView_Previews: PreviewProvider {
    static var previews: some View {
        StoryBodyView(storyImage: .mocks.first!)
    }
}
