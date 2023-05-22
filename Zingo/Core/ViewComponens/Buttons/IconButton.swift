//
//  IconButton.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct IconButton: View {
    var icon: Icon
    let action: () -> Void
    var body: some View {
        
        Button {
            action()
        } label: {
            ZStack{
                Color.black
                Image(icon.rawValue)
                    .frame(width: 20, height: 20)
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            .background(Color.lightGray, in: Circle().stroke())
        }
    }
}

struct IconButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBlack
            VStack{
                IconButton(icon: .letter){}
                IconButton(icon: .arrowLeft){}
                IconButton(icon: .bookmark){}
                IconButton(icon: .plus){}
            }
           
        }
    }
}
