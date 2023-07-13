//
//  VideoTrimBarSlider.swift
//  Zingo
//
//  Created by Bogdan Zykov on 13.07.2023.
//

import SwiftUI
import AVFoundation

struct VideoTrimBarSlider: View {
    let videoURL: URL
    @State var isChangeTrimSlider: Bool = false
    @State private var thumbnailsImages: [ThumbnailImage] = []
    @Binding private var editedRange: ClosedRange<Double>
    @Binding var currentTime: Double
    private let videoRange: ClosedRange<Double>
   
    let trimBarHeight: CGFloat
    let seek: (Double) -> Void
    let onTapTrim: () -> Void
    
    init(
        videoURL: URL,
        videoRange: ClosedRange<Double>,
        editedRange: Binding<ClosedRange<Double>>,
        currentTime: Binding<Double>,
        trimBarHeight: CGFloat = 60,
        onTapTrim: @escaping () -> Void,
        seek: @escaping (Double) -> Void
    ){
        self.videoURL = videoURL
        self._currentTime = currentTime
        self._editedRange = editedRange
        self.videoRange = videoRange
        self.trimBarHeight = trimBarHeight
        self.onTapTrim = onTapTrim
        self.seek = seek
    }
    var body: some View {
        GeometryReader { proxy in
            ZStack{

                thumbnailsImagesSection(weight: proxy.size.width)
                    .vCenter()
                
                RangedSliderView(value: $editedRange,
                                 bounds: videoRange,
                                 onChange: onChangeTrimTime,
                                 frameColor: .white,
                                 trimColor: .black,
                                 fontColor: .white,
                                 bgColor: .black.opacity(0.5),
                                 thumbView: {
                    GeometryReader { proxy in
                        Rectangle()
                            .cornerRadius(8)
                            .blendMode(.destinationOut)
                        timeSlider(size: proxy.size)
                            .opacity(isChangeTrimSlider ? 0 : 1)
                    }
                })
            }
            .onChange(of: editedRange.lowerBound, perform: updateSeekAndTime)
            .onChange(of: editedRange.upperBound, perform: updateSeekAndTime)
            .task {
                await setThumbnailImages(proxy.size)
            }
        }
        .frame(height: trimBarHeight)
    }
}

struct VideoTrimBarSlider_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBlack
            VideoTrimBarSlider.TestView()
                .padding(.horizontal)
        }
    }
}




extension VideoTrimBarSlider{
    
    private func thumbnailsImagesSection(weight: CGFloat) -> some View{
        HStack(spacing: 0){
            ForEach(thumbnailsImages) { trimData in
                if let image = trimData.image{
                    Image(uiImage: image)
                        .centerCropped()
                        .frame(width: weight / CGFloat(thumbnailsImages.count))
                }
            }
        }
        .cornerRadius(8)
        .onTapGesture {
           onTapTrim()
        }
    }
    
    
    private func timeSlider(size: CGSize) -> some View{
        CustomSlider(
            value: Binding(get: {
                currentTime
            }, set: { newValue in
                currentTime = newValue
                seek(newValue)
            }),
            in: editedRange,
            track: {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .frame(width: size.width, height: size.height, alignment: .center)
            }, fill: {
                Rectangle()
                    .foregroundColor(Color.clear)
            }, thumb: {
                Capsule()
                    .foregroundColor(.red)
                    .overlay(alignment: .top) {
                        Image(systemName: "arrowtriangle.down.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 10))
                            .offset(y: -11)
                    }
                    .overlay {
                        Color.clear
                            .frame(width: 50)
                            .contentShape(Rectangle())
                    }
            }, thumbSize: CGSize(width: 6, height: size.height)
        )
    }
    
    private func updateSeekAndTime(_ value: Double){
        seek(value)
        currentTime = value
    }
    
    private func onChangeTrimTime(_ isChange: Bool){
        isChangeTrimSlider = isChange
    }
}


extension VideoTrimBarSlider{
    
    
    struct TestView: View{
        
        @State var currentTime: Double = 2.10
        @State var editedRange: ClosedRange<Double> = 0...10
        var body: some View{
            
            VideoTrimBarSlider(videoURL: URL(string: "google.com")!, videoRange: 0...100, editedRange: $editedRange, currentTime: $currentTime, onTapTrim: {}, seek: {_ in})
        }
    }
    
}

/// Thumbnail image logic
extension VideoTrimBarSlider{
    
    
    
    /// Create and set thumbnail images
    /// Size - bounds size from geometry reader
    private func setThumbnailImages(_ size: CGSize) async{
        guard thumbnailsImages.isEmpty else { return }
        
        let asset = AVAsset(url: videoURL)
        let imagesCount = thumbnailCount(size)
        let duration = try? await asset.load(.duration).seconds
        var offset: Int = 0
        for i in 0..<imagesCount{
            let thumbnailImage = ThumbnailImage(image: asset.getImage(offset))
            offset = i * Int((duration ?? 1) / Double(imagesCount))
            thumbnailsImages.append(thumbnailImage)
        }
    }

    private func thumbnailCount(_ size: CGSize) -> Int {
        let num = size.width / Double(70 / 1.5)
        return Int(ceil(num))
    }
}


struct ThumbnailImage: Identifiable{
    var id: UUID = UUID()
    var image: UIImage?
    
    
    init(image: UIImage? = nil) {
        self.image = image?.resize(to: .init(width: 100, height: 100))
    }
    
    static let mock = [ThumbnailImage(image: .checkmark), ThumbnailImage(image: .checkmark), ThumbnailImage(image: .checkmark)]

}
