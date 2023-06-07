//
//  ScaleView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 07.06.2023.
//

import SwiftUI

struct ScaleView: View {
    
     let minZoom: CGFloat = 1
     let maxZoom: CGFloat = 3
     
     @State private var scale: CGFloat = 1.0
     @State private var lastScale: CGFloat = 1.0
     @State private var magnitudeIsActive: Bool = Bool()
     
     var body: some View {
         
         ZStack {
             
             Circle()
                 .fill(Color.red)
                 .scaleEffect(scale)
                 .gesture(magnificationGesture)

             
         }
         .padding()
         .compositingGroup()
         .shadow(radius: 10.0)
     }

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

struct ScaleView_Previews: PreviewProvider {
    static var previews: some View {
        ScaleView()
    }
}
