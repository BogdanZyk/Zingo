//
//  PopupView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 23.05.2023.
//

import SwiftUI


struct Popup<T: View>: ViewModifier {
    let popup: T
    let alignment: Alignment
    let direction: Direction
    let isPresented: Bool
    
    init(isPresented: Bool, alignment: Alignment, direction: Direction, @ViewBuilder content: () -> T) {
        self.isPresented = isPresented
        self.alignment = alignment
        self.direction = direction
        popup = content()
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(popupContent())
    }
    
    @ViewBuilder
    private func popupContent() -> some View {
        GeometryReader { geometry in
            if isPresented {
                popup
                    .transition(.offset(x: 0, y: direction.offset(popupFrame: geometry.frame(in: .global))))
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: alignment)
            }
        }
    }
}

extension Popup {
    enum Direction {
        case top, bottom
        
        func offset(popupFrame: CGRect) -> CGFloat {
            switch self {
            case .top:
                let aboveScreenEdge = -popupFrame.maxY
                return aboveScreenEdge
            case .bottom:
                let belowScreenEdge = UIScreen.main.bounds.height - popupFrame.minY
                return belowScreenEdge
            }
        }
    }
}

extension View {
    func popup<T: View>(
        isPresented: Bool,
        alignment: Alignment = .center,
        direction: Popup<T>.Direction = .bottom,
        @ViewBuilder content: () -> T
    ) -> some View {
        return modifier(Popup(isPresented: isPresented, alignment: alignment, direction: direction, content: content))
    }
}

private extension View {
    func onGlobalFrameChange(_ onChange: @escaping (CGRect) -> Void) -> some View {
        background(GeometryReader { geometry in
            Color.clear.preference(key: FramePreferenceKey.self, value: geometry.frame(in: .global))
        })
        .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
    }
}

private struct FramePreferenceKey: PreferenceKey {
    static let defaultValue = CGRect.zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private extension View {
    @ViewBuilder func applyIf<T: View>(_ condition: @autoclosure () -> Bool, apply: (Self) -> T) -> some View {
        if condition() {
            apply(self)
        } else {
            self
        }
    }
}



struct PopupTestView: View{
    @State private var isTopSnackbarPresented = false
    var body: some View{
        VStack {
            Button {
                withAnimation(.spring()) {
                    isTopSnackbarPresented.toggle()
                }
                
            } label: {
                Text("Show popup")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popup(isPresented: isTopSnackbarPresented, alignment: .top, direction: .top){
            
        }
    }
}

struct PopupTestView_Previews: PreviewProvider {
    static var previews: some View {
        PopupTestView()
    }
}


struct PopupView: View{
    
    var bgColor: Color
    var delay: Double
    var noReset: Bool
    @Binding var popup: PopupNotify?
    
    init(
        popup: Binding<PopupNotify?>,
        bgColor: Color = .blue,
        delay: Double = 2,
        noReset: Bool = false
    ){
        self._popup = popup
        self.bgColor = bgColor
        self.delay = delay
        self.noReset = noReset
    }
    
    var body: some View {
        VStack(spacing: 0){
            Text(popup?.title ?? "")
                .font(.system(size: 18))
                .foregroundColor(.white)
                .padding(5)
        }
        .hCenter()
        .padding(.vertical, 8)
        .background(popup?.color ?? .lightGray, in: RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            withAnimation(.easeInOut) {
                popup = nil
            }
        }
        .padding(.horizontal)
        .disabled(noReset)
        .onAppear{
            withAnimation(.easeInOut.delay(delay)){
                popup = noReset ? popup : nil
            }
        }
    }
}

extension View{
    func notifyPopup(popup: Binding<PopupNotify?>, noReset: Bool = false) -> some View{
        self
            .popup(isPresented: popup.wrappedValue != nil, alignment: .top, direction: .top){
                PopupView(popup: popup, noReset: noReset)
            }
    }
}


