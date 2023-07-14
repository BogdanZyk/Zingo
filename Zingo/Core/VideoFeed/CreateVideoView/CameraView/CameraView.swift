//
//  CameraView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 05.06.2023.
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    @State private var showVideoEditor: Bool = false
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var selectedVideo: DraftVideo?
    @State private var showPickerLoader: Bool = false
    @State private var scale: CGFloat = 1
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
                        Spacer()
                        changeCameraButton
                    }
                }
            }
            .navigationDestination(isPresented: $showVideoEditor) {
                if let video = cameraManager.draftVideo{
                    PlayerEditorView(video: video)
                }
            }
        }
        .fullScreenCover(item: $selectedVideo) { video in
            VideoEditorPreview(video: video, recordTime: .full, onSave: cameraManager.setVideo)
        }
        .onChange(of: selectedPickerItem) { item in
            Task{
               await loadVideoItem(item)
            }
        }
        .overlay {
            if showPickerLoader{
                Color.darkBlack.opacity(0.5).ignoresSafeArea()
                ProgressView()
                    .tint(.accentPink)
                    .scaleEffect(1.5)
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
            cameraManager.removeAll()
            dismiss()
        } label: {
            buttonLabel("xmark")
        }
    }
    
    
    private var changeCameraButton: some View{
        Button {
            cameraManager.switchCamera()
        } label: {
            buttonLabel("arrow.triangle.2.circlepath")
        }
        .disabled(cameraManager.isExporting)
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
                cameraManager.stopRecord()
            }else{
                cameraManager.startRecording()
            }
        }
        .disabled(cameraManager.isExporting)
        .hCenter()
        .overlay {
            HStack {
                videoPickerButton
                Spacer()
                nextButton
            }
        }
        .padding()
    }

    private var recordTimer: some View{
        Text(cameraManager.recordedDuration.humanReadableShortTime())
            .font(.title3.bold())
            .foregroundColor(.white)
            .opacity(cameraManager.isRecording || cameraManager.timeLimitActive ? 1 : 0)
    }
    
    @ViewBuilder
    private var nextButton: some View{
        if cameraManager.isThereRecords && !cameraManager.isRecording{
            ButtonView(label: "Next", showLoader: cameraManager.isExporting, type: .primary, height: 40, font: .body.bold()) {
                cameraManager.createVideo {
                    showVideoEditor.toggle()
                }
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
        }
    }
    
    @ViewBuilder
    private var videoPickerButton: some View{
        if !cameraManager.isRecording{
            PhotosPicker(selection: $selectedPickerItem, matching: .videos, photoLibrary: .shared()) {
                Image(systemName: "plus")
                    .font(.title3)
                    .bold()
                    .padding(16)
                    .background(Color.lightGray)
                    .cornerRadius(15)
            }
        }
    }
    
    func loadVideoItem(_ selectedItem: PhotosPickerItem?) async{
        showPickerLoader = true
        do {
            if let item = try await selectedItem?.loadTransferable(type: VideoItem.self) {
                self.selectedVideo = await .init(url: item.url, recordsURl: [])
                showPickerLoader = false
            }
        } catch {
            print(error.localizedDescription)
            showPickerLoader = false
        }
    }
}






