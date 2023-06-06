//
//  ScreenRecorderManager.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import AVFoundation
import ReplayKit
import Photos

class ScreenRecorderManager: ObservableObject{
    
    @Published var isRecord: Bool = false
    let recorder = RPScreenRecorder.shared()
    var assetWriter: AVAssetWriter!
    var videoURL: URL!
    var videoInput: AVAssetWriterInput!
    var audioMicInput: AVAssetWriterInput!
    
    
    func startRecoding(){
        let name = "\(Date().ISO8601Format()).mp4"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        self.videoURL = url
        
        setupAssetWriters(url)
        AVAudioSession.sharedInstance().playAndRecord()
        recorder.isMicrophoneEnabled = true
        recorder.startCapture { (cmSampleBuffer, rpSampleBufferType, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            if CMSampleBufferDataIsReady(cmSampleBuffer) {
                DispatchQueue.main.async {
                    
                    switch rpSampleBufferType {
                    case .video:
                        
                        print("writing sample....")
                        
                        if self.assetWriter?.status == AVAssetWriter.Status.unknown {
                            
                            print("Started writing")
                            self.assetWriter?.startWriting()
                            self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(cmSampleBuffer))
                        }
                        
                        if self.assetWriter.status == AVAssetWriter.Status.failed {
                            print("StartCapture Error Occurred, Status = \(self.assetWriter.status.rawValue), \(self.assetWriter.error!.localizedDescription) \(self.assetWriter.error.debugDescription)")
                            return
                        }
                        
                        if self.assetWriter.status == AVAssetWriter.Status.writing {
                            if self.videoInput.isReadyForMoreMediaData {
                                print("Writing a sample")
                                if self.videoInput.append(cmSampleBuffer) == false {
                                    print("problem writing video")
                                }
                            }
                        }
                        
                    case .audioMic:
                        if self.audioMicInput.isReadyForMoreMediaData {
                            print("audioMic data added")
                            self.audioMicInput.append(cmSampleBuffer)
                        }
                        
                    default: break
                    }
                }
            }
        } completionHandler: { error in
            if let error {
                print(error.localizedDescription)
            }else{
                self.isRecord = true
            }
        }
    }
    
    func stop(){
        recorder.stopCapture { (error) in

            if let error{
                print(error.localizedDescription)
                self.isRecord = false
                return
            }
            
            guard let videoInput = self.videoInput,
                  let audioMicInput = self.audioMicInput,
                  let assetWriter = self.assetWriter,
                  let videoURL = self.videoURL else {
                self.isRecord = false
                return
            }

            videoInput.markAsFinished()
            audioMicInput.markAsFinished()
            assetWriter.finishWriting {
                DispatchQueue.main.async {
                    self.isRecord = false
                }
                
                PHPhotoLibrary.shared().performChanges({
                          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                      }) { (saved, error) in

                          if let error = error {
                              print("PHAssetChangeRequest Video Error: \(error.localizedDescription)")
                              return
                          }

                          if saved {
                              print("saved")
                              // ... show success message
                          }
                      }
            }
        }
    }
    
    private func showShareSheet(data: Any){
        UIActivityViewController(activityItems: [data], applicationActivities: nil).presentInKeyWindow()
    }
    
    private func setupAssetWriters(_ url: URL){
        do {
            try assetWriter = AVAssetWriter(outputURL: videoURL, fileType: .mp4)
        } catch {
            print(error.localizedDescription)
        }
        
        let videoCodecType = AVVideoCodecType.h264
        let bitsPerSecond: Int = 25_000_000 // 25 мегабит/секунду
        let profileLevel = AVVideoProfileLevelH264HighAutoLevel
        
        let compression: [String : Any] = [
            AVVideoAverageBitRateKey: bitsPerSecond,
            AVVideoProfileLevelKey: profileLevel,
            AVVideoExpectedSourceFrameRateKey: 60
        ]
        
        let videoOutputSettings: [String: Any] = [
            AVVideoCodecKey: videoCodecType,
            AVVideoWidthKey: UIScreen.main.nativeBounds.width,
            AVVideoHeightKey: UIScreen.main.nativeBounds.height,
            AVVideoCompressionPropertiesKey: compression,
        ]
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        
        if assetWriter.canAdd(videoInput) {
            assetWriter.add(videoInput)
        }
        
        let audioSettings: [String: Any] = [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.0,
            AVEncoderBitRateKey: 192000
        ]
        
        audioMicInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        audioMicInput.expectsMediaDataInRealTime = true
        if assetWriter.canAdd(audioMicInput) {
            assetWriter.add(audioMicInput)
        }
        
    }
}
