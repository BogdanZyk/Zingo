//
//  ChatView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var router: MainRouter
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedConversation: Conversation?
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.conversations) { conversation in
                    Button {
                        router.navigate(to: .dialog(conversation))
                    } label: {
                        chatCell(conversation)
                            .swipeAction{
                                Task{
                                    await viewModel.removeChat(conversation.id)
                                }
                            }
                    }
                    .buttonStyle(CellButton())
                }
            }
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
            .environmentObject(MainRouter())
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
                    HStack {
                        Text(chat.chat.lastMessage?.text ?? "")
                            .font(.body.weight(.light))
                            .lineLimit(1)
                        Spacer()
                        if chat.chat.lastMessage?.didUnViewed(viewModel.currentUserId) ?? false{
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .lineLimit(1)
            }
            .foregroundColor(.white)
            Rectangle()
                .fill(Color.lightWhite.opacity(0.5))
                .frame(height: 0.5)
                .padding(.horizontal, -16)
        }
        .padding([.top, .horizontal])
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


struct CellButton: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        ZStack{
            configuration.label
            if configuration.isPressed{
                Color.lightGray.opacity(0.1)
            }
        }
    }
}
