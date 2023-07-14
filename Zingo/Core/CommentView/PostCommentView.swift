//
//  CommentsView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI

struct CommentsView: View {
    @EnvironmentObject var mainRouter: MainRouter
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CommentViewModel
    
    private var type: CommentsService.CommentType

    var onUpdateCounter: ((Int) -> Void)?
    
    init(parentId: String,
         type: CommentsService.CommentType,
         onUpdateCounter: ((Int) -> Void)? = nil){
        self._viewModel = StateObject(wrappedValue: CommentViewModel(parentId: parentId, type: type))
        self.type = type
        self.onUpdateCounter = onUpdateCounter
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.comments) { comment in
                        commentCell(comment)
                            .id(comment.id)
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.lastCommentId) { newValue in
                withAnimation {
                    proxy.scrollTo(newValue)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color.darkBlack)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            bottomTab
        }
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
           header
        }
        .task {
            await viewModel.getCurrentUser()
        }
        .onAppear{
            if type == .post{
                mainRouter.hiddenTabView = true
            }
        }
        .onDisappear{
            if type == .post{
                mainRouter.hiddenTabView = false
            }
        }
        .onChange(of: viewModel.updateCounter) { _ in
            onUpdateCounter?(viewModel.comments.count)
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(parentId: "09351298-E9D6-4FFF-96A2-3CE6E813E081", type: .video)
            .environmentObject(MainRouter())
    }
}

extension CommentsView{
    
    private func commentCell(_ comment: Comment) -> some View{
        VStack(alignment: .leading){
            HStack(alignment: .top, spacing: 10) {
                UserAvatarView(image: comment.owner.image, size: .init(width: 35, height: 35))
                VStack(alignment: .leading, spacing: 6){
                    
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(comment.owner.name)
                            .font(.callout.bold())
                        Text(comment.createdAt.timeAgo())
                            .font(.footnote)
                            .foregroundColor(.lightGray)
                    }
                    .hLeading()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if type == .video{
                            dismiss()
                        }
                        mainRouter.navigate(to: .userProfile(id: comment.owner.id))
                    }
                    
                    
                    if let text = comment.text{
                        Text(text)
                            .font(.system(size: 16, weight: .medium))
                    }
                    if let image = comment.image{
                        LazyNukeImage(strUrl: image.fullPath, resizeHeight: 200, loadPriority: .high)
                            .frame(width: 200, height: 150)
                            .cornerRadius(12)
                    }
                }
            }
            .foregroundColor(.white)
            Divider()
        }
        .overlay(alignment: .trailing) {
            Label {
                Image(Icon.like.rawValue)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 12, height: 12)
            } icon: {
                if comment.likeCount > 0{
                    Text(verbatim: String(comment.likeCount))
                }
            }
            .font(.footnote)
            .foregroundColor(comment.didLike(viewModel.currentUser?.id) ? .accentPink : .white)
            .vCenter()
            .onTapGesture {
                Task{
                  await viewModel.likeOrUnLike(comment: comment)
                }
            }
        }
    }
    private var bottomTab: some View{
        HStack(alignment: .bottom, spacing: 12){
            UserAvatarView(image: viewModel.currentUser?.profileImage?.fullPath, size: .init(width: 40, height: 40))
            GrowingTextInputView(text: $viewModel.commentText, isRemoveBtn: false, placeholder: "Add your comment", isFocused: false, minHeight: 40)
                .overlay(RoundedRectangle(cornerRadius: 25).strokeBorder(Color.lightWhite, lineWidth: 1))
            ButtonView(label: "Send", type: .primary, height: 40, font: .body.bold(), isDisabled: viewModel.commentText.orEmpty.isEmptyStrWithSpace) {
                Task{
                    await viewModel.sendComment()
                }
            }
            .frame(width: 70)
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 5)
        .background(Color.black)
    }
    
    private var header: some View{
        HStack {
            Text("Comments")
                .font(.title3.bold())
            Text("\(viewModel.comments.count)")
                .foregroundColor(.lightGray)
                .font(.body.bold())
        }
        .padding(.bottom)
        .hCenter()
        .foregroundColor(.white)
        .overlay(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            IconButton(icon: type == .post ? .arrowLeft : .xmark){
                dismiss()
                if type == .post{
                    mainRouter.hiddenTabView = false
                }
            }
            .padding(.leading)
        }
        .padding(.top, type == .post ? 0 : 10)
        .background(Color.darkBlack)
    }
}
