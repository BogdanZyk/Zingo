//
//  FeedView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.posts) { post in
                        PostView(post: post, onRemove: viewModel.removePost)
                        if viewModel.shouldNextPageLoader(post.id){
                            ProgressView()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.darkBlack)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}


extension FeedView{
    private var headerSection: some View{
        HStack{
            Text("Good Morning, Alex.")
                .font(.title2.bold())
                .lineLimit(1)
            Spacer()
            IconButton(icon: .letter) {
                
            }
        }
        .foregroundColor(.white)
        .padding([.bottom, .horizontal])
    }
}
