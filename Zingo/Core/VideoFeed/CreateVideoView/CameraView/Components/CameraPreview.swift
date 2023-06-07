//
//  CameraPreview.swift
//  Zingo
//
//  Created by Bogdan Zykov on 07.06.2023.
//

import SwiftUI

struct CameraPreview: View {
    @ObservedObject var cameraManager: CameraManager
    
    var minZoom: CGFloat {
        cameraManager.cameraInput?.device.minAvailableVideoZoomFactor ?? 1
    }
    var maxZoom: CGFloat {
        cameraManager.cameraInput?.device.maxAvailableVideoZoomFactor ?? 3
    }
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var magnitudeIsActive: Bool = false
    
    
    var body: some View {
        GeometryReader { proxy in
            CameraPreviewHolder(captureSession: cameraManager.session, frame: proxy.frame(in: .local))
                .gesture(magnificationGesture)
        }
        .frame(height: getRect().height / 1.1)
        .cornerRadius(20)
        .vTop()
        .onChange(of: scale) { newValue in
            cameraManager.zoom(newValue)
        }
    }
}

struct CameraPreview_Previews: PreviewProvider {
    static var previews: some View {
        CameraPreview(cameraManager: CameraManager())
    }
}

extension CameraPreview{
    
    var magnificationGesture: some Gesture {
        
        MagnificationGesture(minimumScaleDelta: 0.0)
            .onChanged { value in
                
                if !magnitudeIsActive { magnitudeIsActive = true }
                
                let magnification = (lastScale + value.magnitude - 1.0)
                
                if (magnification >= minZoom && magnification <= maxZoom) {
                    
                    scale = magnification
                    
                }
                else if (magnification < minZoom) {
                    
                    scale = minZoom
                }
                else if (magnification > maxZoom) {
                    
                    scale = maxZoom
                }
                
            }
            .onEnded { value in
                
                let magnification = (lastScale + value.magnitude - 1.0)
                
                if (magnification >= minZoom && magnification <= maxZoom) {
                    
                    lastScale = magnification
                    
                }
                else if (magnification < minZoom) {
                    
                    lastScale = minZoom
                }
                else if (magnification > maxZoom) {
                    
                    lastScale = maxZoom
                }
                
                scale = lastScale
                magnitudeIsActive = false
                
            }
        
    }
    
    
    func resetZoom(){
        scale = minZoom; lastScale = scale
    }
    
}

