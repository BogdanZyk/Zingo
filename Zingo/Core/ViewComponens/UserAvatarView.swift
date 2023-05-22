//
//  UserAvatarView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

struct UserAvatarView: View {
    let image: String?
    var size: CGSize = .init(width: 138, height: 138)
    var body: some View {
        Group{
            if let image{
                LazyNukeImage(strUrl: image, resizingMode: .aspectFill, loadPriority: .high)
            }else{
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.lightGray)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(Circle())
    }
}

struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UserAvatarView(image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_KIEkMvsIZEmzG7Og_h3SJ4T3HsE2rqm3_w&usqp=CAU")
            UserAvatarView(image: nil)
        }
    }
}
