//
//  VideoFeedView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 05.06.2023.
//

import SwiftUI

struct VideoFeedView: View {
    @State private var showCameraView: Bool = false
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
        }
        .background(Color.darkBlack)
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            header
        }
        .fullScreenCover(isPresented: $showCameraView) {
            CameraView()
        }
    }
}

struct VideoFeedView_Previews: PreviewProvider {
    static var previews: some View {
        VideoFeedView()
    }
}


extension VideoFeedView{
    
    private var header: some View{
        
        HStack{
            Text("Feed")
                .font(.title2.bold())
            Spacer()
            Button {
                showCameraView.toggle()
            } label: {
                Image(systemName: "camera.fill")
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        
    }
}
