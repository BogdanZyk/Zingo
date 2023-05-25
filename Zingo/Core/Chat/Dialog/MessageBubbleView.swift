//
//  MessageBubbleView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 25.05.2023.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let recipientType: RecipientType
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text(message.text)
            Text("\(message.createdAt, formatter: Date.hoursAndMinuteFormatter)")
                .font(.system(size: 10))

        }
        .padding(8)
        .background(recipientType.backgroundColor, in: CustomCorner(corners: [recipientType == .received ?  .topLeft : .bottomRight], radius: 4))
        .clipShape(CustomCorner(corners: recipientType.corners, radius: 12))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: recipientType == .sent ? .trailing : .leading)
    }
}

struct MessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 4) {
            MessageBubbleView(message: Message.mocks.first!, recipientType: .received)
            MessageBubbleView(message: Message.mocks.first!, recipientType: .sent)
        }
        .padding()
    }
}



enum RecipientType: String, Codable, Equatable {
    case sent
    case received
}

extension RecipientType {

    var backgroundColor: Color {
        switch self {
        case .sent:
            return .primaryBlue
        case .received:
            return .lightGray
        }
    }
    
    var corners: UIRectCorner{
        switch self {
        case .sent: return [.bottomLeft, .topRight, .topLeft]
        case .received: return [.bottomLeft, .topRight, .bottomRight]
        }
    }
}
