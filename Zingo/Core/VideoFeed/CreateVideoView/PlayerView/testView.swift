//
//  testView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import SwiftUI
import ReplayKit

struct ContentView2: View {
    @StateObject var recorderManager = ScreenRecorderManager()
    private let recorder = RPScreenRecorder.shared()
    @State var rp: RPPreviewView!
    @State private var isRecording = false
    @State private var isShowPreviewVideo = false
    @State private var isBool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            content
                .overlay(alignment: .bottom) {
                    Button(action: {
                        if recorderManager.isRecord {
                            recorderManager.stop()
                        } else {
                            recorderManager.startRecoding()
                        }
                    }) {
                        Image(systemName: recorderManager.isRecord ? "stop.circle" : "play.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding()
                    }
                }
        }
    }
    
    private func startRecord() {
        guard recorder.isAvailable, !recorder.isRecording else {
            print("Recording is not available at this time.")
            return
        }

//        var child = UIHostingController(rootView: content)
//        var parent = UIViewController()
//        child.view.translatesAutoresizingMaskIntoConstraints = false
//        child.view.frame = parent.view.bounds
//        // First, add the view of the child to the view of the parent
//        parent.view.addSubview(child.view)
//        // Then, add the child to the parent
//        parent.addChild(child)

        recorder.isMicrophoneEnabled = true
        recorder.startCapture { buffer, bufferType, error in
            guard error == nil else {
                print("There was an error starting the recording.")
                return
            }
        }
        self.isRecording = true
//        recorder.startRecording { (error) in
//            print("Started Recording Successfully")
//
//        }
        
    }
    
    private func discardRecording(){
        recorder.discardRecording {
            isRecording = false
        }
    }
    private func stopRecord() {
        
        Task{
            let name = "\(Date().ISO8601Format()).mov"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            do{
                try await recorder.stopRecording(withOutput: url)
                await MainActor.run{
                    isRecording = false
                    showShareSheet(data: url)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
       
        
//        recorder.stopRecording { (preview, error) in
//            print("Stopped recording")
//            self.isRecording = false
//            guard let preview = preview else {
//                print("Preview controller is not available.")
//                return
//            }
//
//            self.rp = RPPreviewView(rpPreviewViewController: preview, isShow: self.$isShowPreviewVideo)
//            withAnimation {
//                self.isShowPreviewVideo = true
//            }
//        }
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}

extension ContentView2{
    private var content: some View{
        Text("Hello, World!")
            .font(.title)
            .foregroundColor(isBool ? .red : .green)
            .allFrame()
            .padding()
            .background(Color.gray.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                self.isBool.toggle()
            }
    }
    
    func showShareSheet(data: Any){
        UIActivityViewController(activityItems: [data], applicationActivities: nil).presentInKeyWindow()
    }
}

struct RPPreviewView: UIViewControllerRepresentable {
    let rpPreviewViewController: RPPreviewViewController
    @Binding var isShow: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> RPPreviewViewController {
        rpPreviewViewController.previewControllerDelegate = context.coordinator
        rpPreviewViewController.modalPresentationStyle = .fullScreen
        
        return rpPreviewViewController
    }
    
    func updateUIViewController(_ uiViewController: RPPreviewViewController, context: Context) { }
    
    class Coordinator: NSObject, RPPreviewViewControllerDelegate {
        var parent: RPPreviewView
           
        init(_ parent: RPPreviewView) {
            self.parent = parent
        }
           
        func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
            withAnimation {
                parent.isShow = false
            }
        }
    }
}




