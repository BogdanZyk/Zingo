//
//  DialogView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 25.05.2023.
//

import SwiftUI

struct DialogView: View {
    @EnvironmentObject var mainRouter: MainRouter
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DialogViewModel
    
    
    init(participant: ShortUser, chatId: String){
        _viewModel = StateObject(wrappedValue: DialogViewModel(participant: participant, chatId: chatId))
    }
    
    init(participantId: String){
        _viewModel = StateObject(wrappedValue: DialogViewModel(participantId: participantId))
    }
        
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 6){
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            recipientType: message.getRecipientType(currentUserId: viewModel.currentUserId))
                        .id(message.id)
                            .flippedUpsideDown()
                    }
                }
                .padding([.horizontal, .top])
            }
            .flippedUpsideDown()
            .background(Color.darkBlack)
            .navigationBarBackButtonHidden(true)
            .safeAreaInset(edge: .top) {
                headerView
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomBar
            }
            .onChange(of: viewModel.lastMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id)
                }
            }
        }
        .onAppear{
            mainRouter.hiddenTabView = true
        }
        .onDisappear{
            mainRouter.hiddenTabView = false
        }
        .handle(error: $viewModel.error)
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(participantId: "fTSwHTmYHkeYvfsWASMpEDlwGmg2")
            .environmentObject(MainRouter())
    }
}

extension DialogView{
    
    private var headerView: some View{
        VStack {
            HStack{
                IconButton(icon: .arrowLeft) {
                    mainRouter.hiddenTabView = false
                    dismiss()
                }
                VStack(spacing: 5){
                    UserAvatarView(image: viewModel.participant?.image, size: .init(width: 35, height: 35))
                    Text(viewModel.participant?.name ?? "-")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }.hCenter()
                
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.lightGray)
                }
            }
            Rectangle()
                .fill(Color.lightGray)
                .frame(height: 1)
        }
        .background(Color.darkBlack)
        .padding([.horizontal])
    }
    
    private var bottomBar: some View{
        HStack(spacing: 12){
            GrowingTextInputView(text: $viewModel.text, isRemoveBtn: false, placeholder: "Type your message here...", isFocused: false, minHeight: 45)
                .overlay(RoundedRectangle(cornerRadius: 25).strokeBorder(Color.lightWhite, lineWidth: 1))
            ButtonView(label: "Send", type: .primary, height: 45, font: .body.bold(), isDisabled: viewModel.text.orEmpty.isEmpty) {
                Task{
                  await viewModel.sendMessage()
                }
            }
            .frame(width: 70)
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 5)
        .background(Color.black)
    }
}
