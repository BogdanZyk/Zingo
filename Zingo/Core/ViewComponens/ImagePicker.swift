//
//  ImagePicker.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI
import PhotosUI

struct CameraPicker: UIViewControllerRepresentable{
    
    @Binding var imagesData: [UIImageData]
    var images: [UIImageData] = []
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .camera
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(photoPicker: self)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
        var photoPicker: CameraPicker
        init(photoPicker: CameraPicker){
            self.photoPicker = photoPicker
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.editedImage] as? UIImage{
                var imagePath = UUID().uuidString
                if let url = info[.imageURL] as? URL{
                    imagePath = url.lastPathComponent
                }
                let uiImageData = UIImageData(fileName: imagePath, image: image)
                photoPicker.images.append(uiImageData)
                photoPicker.imagesData = photoPicker.images
            }else{
               print("no image")
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            photoPicker.images = []
            picker.dismiss(animated: true)
        }
    }
}







struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: [UIImageData]
    var selectionLimit: Int = 1
    var images: [UIImageData] = []
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        config.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            let providers = results.compactMap({$0.itemProvider})
            if providers.isEmpty {return}
            
            providers.forEach { provider in
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        let uiImage = image as? UIImage
                        let imageData = UIImageData(fileName: provider.suggestedName ?? "No name", image: uiImage)
                        self.parent.images.append(imageData)
                        DispatchQueue.main.async {
                            self.parent.imageData = self.parent.images
                        }
                    }
                }
            }
        }
    }
}



struct PHPImagePickerModifier: ViewModifier{
    var pickerType: ImagePickerType
    @Binding var show: Bool
    @Binding var imagesData: [UIImageData]
    var onDismiss: (() -> Void)?
    var selectionLimit: Int
    
    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $show, onDismiss: {
                onDismiss?()
            }) {
                Group{
                    if pickerType == .photoLib{
                        ImagePicker(imageData: $imagesData, selectionLimit: selectionLimit)
                    }else{
                        CameraPicker(imagesData: $imagesData)
                    }
                }.preferredColorScheme(.light)
            }
    }
}

extension View {
    
    func imagePicker(pickerType: ImagePickerType, show: Binding<Bool>, imagesData: Binding<[UIImageData]>, selectionLimit: Int = 1, onDismiss: (() -> Void)? = nil) -> some View{
        modifier(PHPImagePickerModifier(pickerType: pickerType, show: show, imagesData: imagesData, onDismiss: onDismiss, selectionLimit: selectionLimit))
    }
}


struct UIImageData: Identifiable{
    var id: String = UUID().uuidString
    var fileName: String
    var image: UIImage?
}

enum ImagePickerType: Int{
    case camera, photoLib
}
