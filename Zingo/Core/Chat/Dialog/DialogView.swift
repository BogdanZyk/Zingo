//
//  DialogView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 25.05.2023.
//

import SwiftUI
import Algorithms

struct DialogView: View {
    @EnvironmentObject var mainRouter: MainRouter
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DialogViewModel
    @State private var hiddenDownButton: Bool = false
    
    init(participant: ShortUser, chatId: String){
        _viewModel = StateObject(wrappedValue: DialogViewModel(participant: participant, chatId: chatId))
    }
    
    init(participantId: String){
        _viewModel = StateObject(wrappedValue: DialogViewModel(participantId: participantId))
    }
        
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                messagesSection
                .padding(10)
            }
            .flippedUpsideDown()
            .background(Color.darkBlack)
            .navigationBarBackButtonHidden(true)
            .scrollDismissesKeyboard(.interactively)
            .overlay(alignment: .bottomTrailing) {
                downButton(proxy)
            }
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
                if let id = viewModel.participant?.id{
                    NavigationLink {
                        UserProfile(userId: id, fromDialog: true)
                    } label: {
                        VStack(spacing: 5){
                            UserAvatarView(image: viewModel.participant?.image, size: .init(width: 35, height: 35))
                            Text(viewModel.participant?.name ?? "-")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }.hCenter()
                    }
                }
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.lightGray)
                }
            }
            CustomDivider()
                .padding(.horizontal, -16)
        }
        .padding(.horizontal)
        .background(Color.darkBlack)
    }
    
    
    
    private var messagesSection: some View{
        LazyVStack(spacing: 6, pinnedViews: .sectionFooters){
            let chunkedMessage = viewModel.messages.chunked(by: {$0.createdAt.isSameDay(as: $1.createdAt)})
            ForEach(chunkedMessage.indices, id: \.self){index in
                Section {
                    ForEach(chunkedMessage[index].uniqued(on: {$0.id})) { message in
                        MessageBubbleView(
                            message: message,
                            recipientType: message.getRecipientType(currentUserId: viewModel.currentUserId))
                        .id(message.id)
                        .flippedUpsideDown()
                        .onAppear{
                            viewModel.viewMessage(message)
                            viewModel.loadNextPage(message.id)
                            hiddenOrUnhiddenDownButton(message.id, hidden: true)
                        }
                        .onDisappear{
                            hiddenOrUnhiddenDownButton(message.id, hidden: false)
                        }
                    }
                } footer: {
                    Text(chunkedMessage[index].first?.createdAt.toFormatDate().capitalized ?? "")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Material.ultraThinMaterial, in: Capsule())
                        .padding(.vertical, 5)
                        .flippedUpsideDown()
                        .padding(.bottom, 10)
                }
            }
        }
    }
    
    private var bottomBar: some View{
        HStack(spacing: 12){
            GrowingTextInputView(text: $viewModel.text, isRemoveBtn: false, placeholder: "Type your message here...", isFocused: false, minHeight: 40)
                .overlay(RoundedRectangle(cornerRadius: 25).strokeBorder(Color.lightWhite, lineWidth: 1))
            sendButton
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 5)
        .background(Color.black)
    }
    
    private var sendButton: some View{
        Button {
            Task{
                await viewModel.sendMessage()
            }
        } label: {
            Image(systemName: "paperplane.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 40)
                .foregroundColor((viewModel.text?.isEmptyStrWithSpace ?? true) ? .lightGray : .accentPink)
        }
        .disabled((viewModel.text?.isEmptyStrWithSpace ?? true))
    }
    
    @ViewBuilder
    private func downButton(_ proxy: ScrollViewProxy) -> some View{
        if !hiddenDownButton{
            Button {
                guard let id = viewModel.messages.first?.id else { return }
                withAnimation {
                    proxy.scrollTo(id)
                }
            } label: {
                Image(systemName: "chevron.down")
                    .padding(10)
                    .background(Color.darkGray.opacity(0.7), in: Circle())
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                    .padding(.trailing, 5)
            }
        }
    }
    
    private func hiddenOrUnhiddenDownButton(_ messageId: String, hidden: Bool){
        if messageId == viewModel.messages.first?.id{
            hiddenDownButton = hidden
        }
    }
    
    
}
