//
//  PrimaryButtonView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 19.05.2023.
//

import SwiftUI

struct ButtonView: View {
    let label: String
    var showLoader: Bool = false
    var type: ButtonType
    var height: CGFloat = 48
    var font: Font = .title3.bold()
    var isDisabled = false
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Group{
                if showLoader{
                    ProgressView()
                }else{
                    Text(label)
                        .font(font)
                }
            }
            .tint(.white)
            .hCenter()
            .frame(height: height)
            .background{
                if type == .border{
                    Capsule()
                        .strokeBorder(lineWidth: 1.5)
                        .foregroundColor(.white)
                }else{
                    Capsule()
                        .fill(type.color)
                }
            }
        }
        .opacity(isDisabled ? 0.6 : 1)
        .disabled(isDisabled)
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            VStack {
                ButtonView(label: "Button", type: .primary, action: {})
                ButtonView(label: "Button", type: .secondary, action: {})
                ButtonView(label: "Button", type: .border, action: {})
                ButtonView(label: "Button", showLoader: true, type: .primary,  action: {})
                ButtonView(label: "Button", type: .primary, isDisabled: true, action: {})
            }
            .padding()
        }
    }
}

extension ButtonView{
    
    
    enum ButtonType{
        case primary, secondary, border
        
        var color: Color{
            switch self{
            case .primary: return .accentPink
            case .secondary: return .darkBlack
            case .border: return .darkGray
            }
        }
    }
}
