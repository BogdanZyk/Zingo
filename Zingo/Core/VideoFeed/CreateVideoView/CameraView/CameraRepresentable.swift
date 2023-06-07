//
//  CameraRepresentable.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import SwiftUI
import AVKit


struct CameraPreviewHolder: UIViewRepresentable{
    
    typealias UIViewType = CameraPreviewView
    
    var captureSession: AVCaptureSession
    var frame: CGRect
    
    func makeUIView(context: Context) -> CameraPreviewView {
        CameraPreviewView(captureSession: captureSession, frame: frame)
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        
    }
}

extension CameraPreviewHolder{
    
    class CameraPreviewView: UIView{
        
        private var captureSession: AVCaptureSession
        let viewFrame: CGRect
        
        init(captureSession: AVCaptureSession, frame: CGRect) {
            self.captureSession = captureSession
            self.viewFrame = frame
            super.init(frame: frame)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override class var layerClass: AnyClass{
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer{
            return layer as! AVCaptureVideoPreviewLayer
        }
        
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            
            if nil != self.superview{
                self.videoPreviewLayer.session = self.captureSession
                self.videoPreviewLayer.frame = self.viewFrame
                self.videoPreviewLayer.videoGravity = .resizeAspectFill
            }else{
                self.videoPreviewLayer.session = nil
                self.videoPreviewLayer.removeFromSuperlayer()
            }
        }
    }

}
