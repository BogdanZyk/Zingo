//
//  PostEditorView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct PostEditorView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack{
            header
        }
        .allFrame()
        .background(Color.darkBlack)
    }
}

struct PostEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PostEditorView()
    }
}

extension PostEditorView{
    
    private var header: some View{
        HStack{
            Button {
                
            } label: {
                Text("Discard")
                    .font(.footnote.bold())
            }
            Spacer()
            ButtonView(label: "Publish", showLoader: false, type: .primary, height: 30, font: .body) {
            }
            .frame(width: 80)
        }
        
        .padding(.horizontal)
        .overlay {
            Text("Create")
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }
    
}
