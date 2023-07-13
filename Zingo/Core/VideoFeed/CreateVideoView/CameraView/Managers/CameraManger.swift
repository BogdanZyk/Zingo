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
    @Published private(set) var session = AVCaptureSession()
    @Published private(set) var draftVideo: DraftVideo?
    @Published private(set) var recordedDuration: Double = .zero
    @Published private(set) var isExporting: Bool = false
    @Published private(set) var isRecording: Bool = false
    @Published var cameraPosition: AVCaptureDevice.Position = .front
    @Published var recordTime: RecordTime = .half
    
    
    private var timer: Timer?
    private let sessionQueue = DispatchQueue(label: "com.Zingo.recorder")
    private let videoOutput = AVCaptureMovieFileOutput()
    var cameraInput: AVCaptureDeviceInput?
    private var status: Status = .unConfig
    private var recordsURl = [URL]()
    
    var timeLimitActive: Bool{
        recordedDuration >= Double(recordTime.rawValue)
    }
    
    var isThereRecords: Bool{
        !recordsURl.isEmpty
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
       
       ///Search devices for params
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
       
        for device in discoverySession.devices {
            if device.position == position {
                
                try? device.lockForConfiguration()
                device.videoZoomFactor = 1
                if position == .back{
                    device.focusMode = .autoFocus
                }
                device.unlockForConfiguration()
                
                return device
            }
        }
        return nil
    }
    
    func stopRecord(){
        print("stop")
        timer?.invalidate()
        timer = nil
        videoOutput.stopRecording()
    }
    
    func startRecording(){
        let tempURL = URL.temporaryDirectory.appending(path: "record_\(Date().ISO8601Format()).mp4")
        videoOutput.startRecording(to: tempURL, recordingDelegate: self)
        videoOutput.maxRecordedDuration = .init(seconds: Double(recordTime.rawValue), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        startTimer()
    }
    
    func changeRecordTime(){
        recordTime = recordTime == .full ? .half : .full
    }
    
    func removeAll(){
        
        let fileManager = FileManager.default
        
        if let draftVideoURL = draftVideo?.url{
            fileManager.removeFileIfExists(for: draftVideoURL)
        }
    
        recordsURl.forEach({fileManager.removeFileIfExists(for: $0)})
    }
}

extension CameraManager{
    

    func switchCamera(){
        
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
            recordedDuration += 0.1
        }else{
            print("auto stop")
            stopRecord()
        }
    }
    
    private func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (timer) in
                self?.onTimerFires()
            }
        }
    }
}



extension CameraManager: AVCaptureFileOutputRecordingDelegate{
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        self.isRecording = true
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        self.isRecording = false
        
        if let error{
            self.error = .outputError(error)
            return
        }
        
        self.recordsURl.append(outputFileURL)
    }
    
    
    func createVideo(completion: @escaping () -> Void){
        
        isExporting = true
        Task{
            do{
                let url = try await VideoEditorHelper.share.createVideo(for: recordsURl)
                let video = await DraftVideo(url: url, recordsURl: recordsURl)
                await MainActor.run {
                    self.draftVideo = video
                    isExporting = false
                    completion()
                }
                
            }catch{
                print("Merge video error", error.localizedDescription)
                isExporting = false
            }
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




