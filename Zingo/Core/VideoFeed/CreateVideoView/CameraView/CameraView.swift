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
    @State var scale: CGFloat = 1
    var body: some View {
        NavigationStack {
            ZStack{
                CameraPreview(cameraManager: cameraManager)
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
                    if !cameraManager.isRecording{
                        VStack{
                            closeButton
                            totalRecordTimeButton
                        }
                    }
                    Spacer()
                    changeCameraButton
                }
            }
            .navigationDestination(isPresented: $showVideoEditor) {
                if let video = cameraManager.draftVideo{
                    PlayerEditorView(video: video)
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
            cameraManager.switchCameraAndStart()
        } label: {
            buttonLabel("arrow.triangle.2.circlepath")
        }
    }
    
    
    private func buttonLabel(_ image: String) -> some View{
        Image(systemName: image)
            .font(.callout.bold())
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .background(Color.white.opacity(0.3))
            .clipShape(Circle())
            .padding()
    }
    
    private var recordButton: some View{
        RecordButton(isPlay: cameraManager.isRecording,
                     totalSec: CGFloat(cameraManager.recordTime.rawValue),
                     progress: cameraManager.recordedDuration,
                     isDisabled: cameraManager.timeLimitActive){
            if cameraManager.isRecording{
                cameraManager.stopRecord(.user)
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
        Text(cameraManager.recordedDuration.formatterTimeString())
            .font(.title3.bold())
            .foregroundColor(.white)
            .opacity(cameraManager.isRecording || cameraManager.timeLimitActive ? 1 : 0)
    }
    
    @ViewBuilder
    private var nextButton: some View{
        if cameraManager.draftVideo != nil && !cameraManager.isRecording{
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
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.3))
                .clipShape(Circle())
                .padding()
                .opacity(cameraManager.timeLimitActive ? 0.5 : 1)
        }
        .disabled(cameraManager.timeLimitActive)
    }
}





