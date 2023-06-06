//
//  RecordButton.swift
//  Zingo
//
//  Created by Bogdan Zykov on 05.06.2023.
//

import SwiftUI

struct RecordButton: View {
    let totalSec: CGFloat
    let progress: CGFloat
    @Namespace private var animation
    @State private var isPlay: Bool = false
    let onTap: () -> Void
    var size2: CGFloat{
        isPlay ? 90 : 75
    }
    
    var size1: CGFloat{
        isPlay ? 30 : 65
    }
    
    
    var body: some View {
        Button {
            onTap()
            withAnimation(.easeInOut(duration: 0.2)) {
                isPlay.toggle()
            }
        } label: {
            
            ZStack {
                Group{
                    if isPlay{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "RecordButton", in: animation)
                    }else{
                        Circle()
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "RecordButton", in: animation)
                    }
                    
                }
                .frame(width: size1, height: size1)
            }
            .frame(width: size2, height: size2)
            .background(Material.ultraThinMaterial, in: Circle())
            .overlay {
                if !isPlay{
                    Circle()
                        .stroke(lineWidth: 3)
                        .foregroundColor(.white)
                }else{
                    CircleProgressBar(total: totalSec, progress: progress, lineWidth: 8, bgCircleColor: .clear, primaryCircleColor: .accentPink)
                        .padding(4)
                }
            }
        }
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBlack
            RecordButton(totalSec: 60, progress: 10){}
        }
    }
}
