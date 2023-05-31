//
//  StoryLoadingBar.swift
//  Zingo
//
//  Created by Bogdan Zykov on 31.05.2023.
//

import SwiftUI

struct StoryLoadingBar: View {
    var progress: CGFloat
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading){
                Capsule()
                    .foregroundColor(.white.opacity(0.5))
                Capsule()
                    .frame(width: proxy.size.width * progress, alignment: .leading)
                    .foregroundColor(.white)
            }
        }
    }
}

struct StoryLoadingBar_Previews: PreviewProvider {
    static var previews: some View {
        StoryLoadingBar(progress: 0)
    }
}
