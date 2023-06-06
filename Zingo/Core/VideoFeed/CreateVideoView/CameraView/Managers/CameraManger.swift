//
//  CameraManger.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import SwiftUI
import AVFoundation



final class CameraManager: NSObject, ObservableObject{
    
    enum Status{
        case unConfig
        case config
        case unauthorized
        case failed
    }
    
    @Published var error: CameraError?
    @Published var session = AVCaptureSession()
    @Published var finalURL: URL?
    @Published var recordedDuration: Double = .zero
    @Published var cameraPosition: AVCaptureDevice.Position = .front
    @Published var recordTime: RecordTime = .half
    
    private var timer: Timer?
    private let sessionQueue = DispatchQueue(label: "com.VideoEditorSwiftUI")
    private let videoOutput = AVCaptureMovieFileOutput()
    private var status: Status = .unConfig
    
    var isRecording: Bool{
        videoOutput.isRecording
    }
    
    override init(){
        super.init()
        config()
    }
    
    private func config(){
        checkPermissions()
        sessionQueue.async {
            self.configCaptureSession()
            self.session.startRunning()
        }
    }
    
    func controllSession(start: Bool){
        guard status == .config else {
            config()
            return
        }
        sessionQueue.async {
            if start{
                if !self.session.isRunning{
                    self.session.startRunning()
                }
            }else{
                self.session.stopRunning()
            }
        }
    }
    
    private func setError(_ error: CameraError?){
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    ///Check user permissions
    private func checkPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { aurhorized in
                if !aurhorized{
                    self.status = .unauthorized
                    self.setError(.deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            setError(.restrictedAuthorization)
        case .denied:
            status = .unauthorized
            setError(.deniedAuthorization)
            
        case .authorized: break
        @unknown default:
            status = .unauthorized
            setError(.unknowAuthorization)
        }
    }
    
    ///Configuring a session and adding video, audio input and adding video output
    private func configCaptureSession(){
        guard status == .unConfig else {
            return
        }
        session.beginConfiguration()
        
        session.sessionPreset = .hd1280x720
        
        let device = getCameraDevice(for: .back)
        let audioDevice = AVCaptureDevice.default(for: .audio)
        
        guard let camera = device, let audio = audioDevice else {
            setError(.cameraUnavalible)
            status = .failed
            return
        }
        
        do{
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            let audioInput = try AVCaptureDeviceInput(device: audio)
            
            if session.canAddInput(cameraInput) && session.canAddInput(audioInput){
                session.addInput(audioInput)
                session.addInput(cameraInput)
            }else{
                setError(.cannotAddInput)
                status = .failed
                return
            }
        }catch{
            setError(.createCaptureInput(error))
            status = .failed
            return
        }
        
        if session.canAddOutput(videoOutput){
            session.addOutput(videoOutput)
        }else{
            setError(.cannotAddInput)
            status = .failed
            return
        }
        
        session.commitConfiguration()
    }
    
    
   private func getCameraDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInDualWideCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func stopRecord(){
        print("stop")
        timer?.invalidate()
        videoOutput.stopRecording()
    }
    
    func startRecording(){
        ///Temporary URL for recording Video
        let tempURL = NSTemporaryDirectory() + "\(Date().ISO8601Format()).mov"
        print(tempURL)
        videoOutput.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        videoOutput.maxRecordedDuration = .init(seconds: Double(recordTime.rawValue), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        startTimer()
    }
    
//    func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
//             queue: DispatchQueue){
//        sessionQueue.async {
//            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
//        }
//    }
    
    func changeRecordTime(){
        recordTime = recordTime == .full ? .half : .full
    }
    
    func removeVideo(){
        guard let url = videoOutput.outputFileURL else {return}
        FileManager.default.removeFileExists(for: url)
    }
}



extension CameraManager{
    
    private func onTimerFires(){
        
        if recordedDuration <= Double(recordTime.rawValue) && videoOutput.isRecording{
            print("🟢 RECORDING")
            recordedDuration += 1
        }
//        if recordedDuration >= Double(recordTime.rawValue) && videoOutput.isRecording{
//            stopRecord()
//        }
    }
    
    private func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
                self?.onTimerFires()
            }
        }
    }
}



extension CameraManager: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(outputFileURL)
        timer?.invalidate()
        if let error{
            self.error = .outputError(error)
        }else{
            self.finalURL = outputFileURL
        }
    }
    
    
}



enum CameraError: Error{
    
    case deniedAuthorization
    case restrictedAuthorization
    case unknowAuthorization
    case cameraUnavalible
    case cannotAddInput
    case createCaptureInput(Error)
    case outputError(Error)
}

extension CameraManager{
    enum RecordTime: Int{
        case half = 30
        case full = 15
    }
}
