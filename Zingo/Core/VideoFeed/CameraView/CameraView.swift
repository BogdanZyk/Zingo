//
//  CameraView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 05.06.2023.
//

import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recordTime: RecordTime = .half
    var body: some View {
        NavigationStack {
            ZStack{
                RoundedRectangle(cornerRadius: 30)
                VStack {
                    recordTimer
                    Spacer()
                    recordButton
                }
                .padding()
            }
            .background(Color.darkBlack.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .overlay(alignment: .top) {
                HStack(alignment: .top) {
                    closeButton
                    Spacer()
                    VStack{
                        changeCameraButton
                        totalRecordTimeButton
                    }
                }
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

extension CameraView{
    
    private var closeButton: some View{
        Button {
            dismiss()
        } label: {
            buttonLabel("xmark")
        }
    }
    
    private var changeCameraButton: some View{
        Button {
            
        } label: {
            buttonLabel("arrow.triangle.2.circlepath")
        }
    }
    
    
    private func buttonLabel(_ image: String) -> some View{
        Image(systemName: image)
            .font(.callout.bold())
            .foregroundColor(.white)
            .padding(10)
            .background(Color.white.opacity(0.3))
            .clipShape(Circle())
            .padding()
    }
    
    private var recordButton: some View{
        RecordButton(totalSec: 60, progress: 10){}
            .hCenter()
            .overlay(alignment: .trailing) {
                nextButton
                
            }
            .padding()
    }

    private var recordTimer: some View{
        Text(11.formatterTimeString())
            .font(.title3.bold())
            .foregroundColor(.white)
            .opacity(1)
    }
    
    private var nextButton: some View{
        ButtonView(label: "Next", type: .primary, height: 40, font: .body.bold()) {
            
        }
        .frame(width: 80)
    }
    
    private var totalRecordTimeButton: some View{
        Button {
            recordTime = recordTime == .full ? .half : .full
        } label: {
            Text(verbatim: String(recordTime.rawValue))
                .font(.callout.bold())
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.3))
                .clipShape(Circle())
                .padding()
        }
    }
}


enum RecordTime: Int{
    case half = 30
    case full = 15
}



extension Double{
    
    func formatterTimeString() -> String{
        let minutes = Int(self / 60)
          let seconds = Int(self.truncatingRemainder(dividingBy: 60))
          return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
}
