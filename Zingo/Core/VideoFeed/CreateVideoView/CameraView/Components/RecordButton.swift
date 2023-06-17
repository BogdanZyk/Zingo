//
//  RecordButton.swift
//  Zingo
//
//  Created by Bogdan Zykov on 05.06.2023.
//

import SwiftUI

struct RecordButton: View {
    var isPlay: Bool
    let totalSec: CGFloat
    let progress: CGFloat
    var isDisabled: Bool = false
    @Namespace private var animation
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
                            .opacity(isDisabled ? 0.5 : 1)
                            .matchedGeometryEffect(id: "RecordButton", in: animation)
                    }
                }
                .frame(width: size1, height: size1)
            }
            .frame(width: size2, height: size2)
            .background(Material.ultraThinMaterial, in: Circle())
            .overlay {
                if !isPlay{
                    if progress > 0{
                        CircleProgressBar(total: totalSec, progress: progress, lineWidth: 4, bgCircleColor: .clear, primaryCircleColor: .accentPink)
                    }else{
                        Circle()
                            .stroke(lineWidth: 3)
                            .foregroundColor(.white)
                    }
                }else{
                    CircleProgressBar(total: totalSec, progress: progress, lineWidth: 8, bgCircleColor: .clear, primaryCircleColor: .accentPink)
                        .padding(4)
                }
            }
        }
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.2), value: isPlay)
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBlack
            VStack{
                RecordButton(isPlay: false, totalSec: 60, progress: 10){}
                RecordButton(isPlay: true, totalSec: 60, progress: 10){}
                RecordButton(isPlay: false, totalSec: 60, progress: 10, isDisabled: true){}
            }
        }
    }
}
