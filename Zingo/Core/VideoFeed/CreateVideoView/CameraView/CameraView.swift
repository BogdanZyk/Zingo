//
//  CameraView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 05.06.2023.
//

import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    @State private var showVideoEditor: Bool = false
    var body: some View {
        NavigationStack {
            ZStack{
                CameraPreviewHolder(captureSession: cameraManager.session)
                    .cornerRadius(20)
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
            .navigationDestination(isPresented: $showVideoEditor) {
                if let url = cameraManager.finalURL{
                    PlayerEditorView(video: Video(url: url, originalDuration: cameraManager.recordedDuration))
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
            cameraManager.removeVideo()
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
        RecordButton(totalSec: CGFloat(cameraManager.recordTime.rawValue), progress: cameraManager.recordedDuration){
            if cameraManager.isRecording{
                cameraManager.stopRecord()
            }else{
                cameraManager.startRecording()
            }
            
        }
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
            .opacity(cameraManager.isRecording ? 1 : 0)
    }
    
    @ViewBuilder
    private var nextButton: some View{
        if cameraManager.finalURL != nil{
            ButtonView(label: "Next", type: .primary, height: 40, font: .body.bold()) {
                showVideoEditor.toggle()
            }
            .frame(width: 80)
        }
    }
    
    private var totalRecordTimeButton: some View{
        Button {
            cameraManager.changeRecordTime()
        } label: {
            Text(verbatim: String(cameraManager.recordTime.rawValue))
                .font(.callout.bold())
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.3))
                .clipShape(Circle())
                .padding()
        }
    }
}






extension Double{
    
    func formatterTimeString() -> String{
        let minutes = Int(self / 60)
          let seconds = Int(self.truncatingRemainder(dividingBy: 60))
          return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
}
