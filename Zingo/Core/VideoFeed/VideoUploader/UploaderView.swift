//
//  UploaderView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 12.07.2023.
//

import SwiftUI

struct UploaderView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var uploader: VideoUploaderManager
    @State var showAlert: Bool = false
    var body: some View {
        HStack{
            if uploader.loadState != .error{
                ZStack {
                    CircleProgressBar(total: 100, progress: uploader.progress, lineWidth: 5, bgCircleColor: .lightWhite, primaryCircleColor: .accentPink)
                    Button {
                        showAlert.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .bold()
                    }
                }
                .frame(width: 30, height: 30)
                Text("Uploading video")
                    .bold()
            }else{
                Text("Uploading error")
                    .bold()
                Button {
                    uploader.tryAgain()
                } label: {
                    Text("Try again")
                }
            }
        }
        .padding()
        .foregroundColor(.white)
        .background(Material.ultraThinMaterial)
        .cornerRadius(10)
        .onChange(of: scenePhase) { newValue in
            switch newValue{
            case .background, .inactive:
                uploader.pause()
            case .active:
                uploader.resume()
            default:
                uploader.pause()
            }
        }
        .alert("Remove video download?", isPresented: $showAlert) {
            Button("Cancel", role: .cancel, action: {})
            Button("Ok", role: .destructive, action: uploader.cancel)
        }
    }
}

struct UploaderView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBlack
            UploaderView(uploader: VideoUploaderManager(user: .mock))
        }
    }
}
