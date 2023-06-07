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
    var cameraInput: AVCaptureDeviceInput?
    private var status: Status = .unConfig
    private var recordsURl = [URL]()
    private var stopInitiatorType: StopInitiator = .empty
    
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
    
    func zoom(_ zoomFactor: CGFloat){
        guard let device = cameraInput?.device else {return}
        try? device.lockForConfiguration()
        device.ramp(toVideoZoomFactor: zoomFactor, withRate: 15)
        device.unlockForConfiguration()
    }
    
    ///Configuring a session and adding video, audio input and adding video output
    private func configCaptureSession(){
        guard status == .unConfig else {
            return
        }
        session.beginConfiguration()
        
        session.sessionPreset = .hd1280x720
        
        let device = getCameraDevice(for: cameraPosition)
        let audioDevice = AVCaptureDevice.default(for: .audio)
        
        guard let camera = device, let audio = audioDevice else {
            setError(.cameraUnavalible)
            status = .failed
            return
        }
        
        do{
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            let audioInput = try AVCaptureDeviceInput(device: audio)
            self.cameraInput = cameraInput
            
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
                
                try? device.lockForConfiguration()
                device.videoZoomFactor = 1.5
                if position == .back{
                    device.focusMode = .autoFocus
                }
                device.unlockForConfiguration()
                
                return device
            }
        }
        return nil
    }
    
    func stopRecord(_ type: StopInitiator){
        print("stop")
        self.stopInitiatorType = type
        timer?.invalidate()
        timer = nil
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
    
    func changeRecordTime(){
        recordTime = recordTime == .full ? .half : .full
    }
    
    func removeVideo(){
        guard let url = videoOutput.outputFileURL else {return}
        FileManager.default.removeFileExists(for: url)
    }
}

extension CameraManager{
    
    
    
    func switchCameraAndStart(){
        stopRecord(.onSwitch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.switchCamera()
            if self.isRecording{
                self.startRecording()
            }
        }
    }
    
    private func switchCamera() {
        
        
        //Indicate that some changes will be made to the session
        session.beginConfiguration()
        cameraPosition = cameraPosition == .back ? .front : .back
        //Get new input
        guard let newCamera = getCameraDevice(for: cameraPosition),
              let newAudio = AVCaptureDevice.default(for: .audio)
        else {
            print("ERROR: Issue in cameraWithPosition() method")
            return
        }
        
        do {
            let audioInput = try AVCaptureDeviceInput(device: newAudio)
            let newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            self.cameraInput = newVideoInput
            
            //remove all inputs in inputs array
            while session.inputs.count > 0 {
                session.removeInput(session.inputs[0])
            }
            
            session.addInput(newVideoInput)
            session.addInput(audioInput)
            
        } catch {
            print("Error creating capture device input: \(error.localizedDescription)")
        }
        
        //Commit all the configuration changes at once
        session.commitConfiguration()
    }
}


extension CameraManager{
    
    private func onTimerFires(){
        
        if recordedDuration <= Double(recordTime.rawValue) && videoOutput.isRecording{
            print("🟢 RECORDING")
            recordedDuration += 1
        }
        if recordedDuration >= Double(recordTime.rawValue) && videoOutput.isRecording{
            stopRecord(.auto)
        }
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
        
        if let error{
            self.error = .outputError(error)
            return
        }
        
        self.recordsURl.append(outputFileURL)
        
        if recordsURl.count != 0 && stopInitiatorType != .onSwitch{
            print(recordsURl)
            self.finalURL = recordsURl.last
        }
        
       else{
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

extension CameraManager{
    enum StopInitiator: Int{
        case user, auto, onSwitch, empty
    }
}
