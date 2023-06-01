//
//  GrowingTextInputView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import SwiftUI

struct GrowingTextInputView: View {
    init(text: Binding<String?>, isRemoveBtn: Bool = true, placeholder: String?, isFocused : Bool = false, minHeight: CGFloat = 35, font: UIFont = .systemFont(ofSize: 16)) {
        self._text = text
        self.isRemoveBtn = isRemoveBtn
        self.placeholder = placeholder
        self.isFocused = isFocused
        self.minHeight = minHeight
        self.font = font
        
    }
    
    @Binding var text: String?
    @State var focused: Bool = false
    @State var contentHeight: CGFloat = 0
    
    let font: UIFont
    let isRemoveBtn: Bool
    let placeholder: String?
    let minHeight: CGFloat
    private var maxHeight: CGFloat { minHeight * 4 }
    let isFocused : Bool
    
    private var countedHeight: CGFloat {
        min(max(minHeight, contentHeight), maxHeight)
    }
    
    private var showPlaceholder: Bool {
        text.orEmpty.isEmpty == true
    }
    
    var body: some View {
        
        
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .topLeading){
                placeholderView
                TextViewWrapper(text: $text, focused: $focused, contentHeight: $contentHeight, font: font)
                    .padding(.trailing, isRemoveBtn ? 25 : 10)
                    .padding(.leading, 10)
            }
            if isRemoveBtn && !showPlaceholder{
                Button {
                    text?.removeAll()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.lightGray)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                }
            }
        }
        .frame(height: countedHeight)
    }
    
    private var placeholderView: some View {
        Text(placeholder ?? "")
            .font(Font(font))
            .foregroundColor(.white)
            .opacity(showPlaceholder ? 0.5 : 0)
            .animation(nil, value: placeholder)
            .offset(x: 14, y: 8)
    }
    
}







struct GrowingTextInputView_Previews: PreviewProvider {
  @State static var text: String?

  static var previews: some View {
      ZStack{
          Color.darkBlack
          GrowingTextInputView(text: .constant(""), isRemoveBtn: false, placeholder: "Add your comment", isFocused: false, minHeight: 40)
              .overlay(RoundedRectangle(cornerRadius: 25).strokeBorder(Color.lightWhite, lineWidth: 1))
              .padding()
      }
  }
}




struct TextViewWrapper: UIViewRepresentable {
    
    init(text: Binding<String?>, focused: Binding<Bool>, contentHeight: Binding<CGFloat>, font: UIFont = .systemFont(ofSize: 18)) {
        self._text = text
        self._focused = focused
        self._contentHeight = contentHeight
        self.font = font
    }
    
    @Binding var text: String?
    @Binding var focused: Bool
    @Binding var contentHeight: CGFloat
    var font: UIFont
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = font
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.autocorrectionType = .default
        textView.delegate = context.coordinator
        textView.keyboardDismissMode = .interactive
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, focused: $focused, contentHeight: $contentHeight)
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        init(text: Binding<String?>, focused: Binding<Bool>, contentHeight: Binding<CGFloat>) {
            self._text = text
            self._focused = focused
            self._contentHeight = contentHeight
        }
        
        @Binding private var text: String?
        @Binding private var focused: Bool
        @Binding private var contentHeight: CGFloat
        
        // MARK: - UITextViewDelegate
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            contentHeight = textView.contentSize.height
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            focused = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            focused = false
            contentHeight = text == nil ? 0 : textView.contentSize.height
        }
    }
}





