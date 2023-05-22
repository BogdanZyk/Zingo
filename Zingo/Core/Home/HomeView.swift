//
//  HomeView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    ForEach(Post.mockPosts) { post in
                        PostView(post: post)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.darkBlack)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


extension HomeView{
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
