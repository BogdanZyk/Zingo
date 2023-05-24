//
//  ImageSliderView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI

struct ImageSliderView: View {
    @State private var selection = 0
    let imagesUrl: [String]
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                ForEach(imagesUrl.indices, id: \.self) { index in
                    LazyNukeImage(strUrl: imagesUrl[index], resizeHeight: 400, resizingMode: .aspectFill, loadPriority: .high)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)
            HStack(spacing: 5){
                ForEach(imagesUrl.indices, id: \.self) { index in
                    Circle()
                        .fill(selection == index ? Color.accentPink : .lightGray)
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView(imagesUrl: Post.mockPosts.last?.images.compactMap({$0.fullPath}) ?? [])
    }
}
