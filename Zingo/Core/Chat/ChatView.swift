//
//  ChatView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.conversations) { chat in
                    NavigationLink {
                        DialogView(participant: chat.conversationUser, chatId: chat.id)
                    } label: {
                        chatCell(chat)
                    }
                }
            }
            .padding()
        }
        .background(Color.darkBlack)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .top) {
            headerView
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}


extension ChatView{
    
    
    private func chatCell(_ chat: Conversation) -> some View{
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16){
                UserAvatarView(image: chat.conversationUser.image, size: .init(width: 40, height: 40))
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chat.conversationUser.name)
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Text(chat.chat.lastMessage?.createdAt.timeAgo() ?? "")
                            .font(.footnote)
                            .foregroundColor(.lightGray)
                    }
                    Text(chat.chat.lastMessage?.text ?? "")
                        .font(.body.weight(.light))
                }
                .lineLimit(1)
                
                if chat.chat.lastMessage?.didUnViewed(viewModel.currentUserId) ?? false{
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 10, height: 10)
                }
            }
            .foregroundColor(.white)
            Rectangle()
                .fill(Color.lightWhite.opacity(0.5))
                .frame(height: 0.5)
                .padding(.horizontal, -16)
        }
        .contentShape(Rectangle())
        .contextMenu{
            Button(role: .destructive) {
                Task{
                    await viewModel.removeChat(chat.id)
                }
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }
    
    private var headerView: some View{
        Text("Messages")
            .foregroundColor(.white)
            .font(.title3.bold())
            .hCenter()
            .padding(.bottom)
            .background(Color.darkBlack)
            .overlay(alignment: .topLeading) {
                IconButton(icon: .arrowLeft) {
                    dismiss()
                }
                .padding(.leading)
            }
    }
    
}
