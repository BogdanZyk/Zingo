//
//  PostCommentView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 24.05.2023.
//

import SwiftUI

struct PostCommentView: View {
    @EnvironmentObject var mainRouter: MainRouter
    @Environment(\.dismiss) private var dismiss
    @Binding var post: Post
    @StateObject private var viewModel: CommentViewModel
    
    init(post: Binding<Post>){
        self._post = post
        self._viewModel = StateObject(wrappedValue: CommentViewModel(postId: post.id))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.comments) { comment in
                    commentCell(comment)
                }
            }
            .padding()
        }
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
            mainRouter.hiddenTabView = true
        }
        .onDisappear{
            mainRouter.hiddenTabView = false
        }
        .onChange(of: viewModel.updateCounter) { _ in
            post.comments = viewModel.comments.count
        }
    }
}

struct PostCommentView_Previews: PreviewProvider {
    static var previews: some View {
        PostCommentView(post: .constant(Post.mockPosts.last!))
            .environmentObject(MainRouter())
    }
}

extension PostCommentView{
    
    private func commentCell(_ comment: Comment) -> some View{
        VStack(alignment: .leading){
            HStack(alignment: .top, spacing: 10) {
                UserAvatarView(image: comment.owner.image, size: .init(width: 35, height: 35))
                VStack(alignment: .leading, spacing: 6){
                    NavigationLink {
                        UserProfile(userId: comment.owner.id)
                    } label: {
                        HStack(alignment: .firstTextBaseline) {
                            Text(comment.owner.name)
                                .font(.callout.bold())
                            Text(comment.createdAt.timeAgo())
                                .font(.footnote)
                                .foregroundColor(.lightGray)
                        }
                        .hLeading()
                        .contentShape(Rectangle())
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
        HStack(spacing: 12){
            UserAvatarView(image: viewModel.currentUser?.profileImage?.fullPath, size: .init(width: 45, height: 45))
            GrowingTextInputView(text: $viewModel.commentText, isRemoveBtn: false, placeholder: "Add your comment", isFocused: false, minHeight: 45)
                .overlay(RoundedRectangle(cornerRadius: 25).strokeBorder(Color.lightWhite, lineWidth: 1))
            ButtonView(label: "Send", type: .primary, height: 45, font: .body.bold(), isDisabled: viewModel.commentText.orEmpty.isEmpty) {
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
        Text("Comments")
            .font(.title3.bold())
            .padding(.bottom)
            .hCenter()
            .background(Color.darkBlack)
            .foregroundColor(.white)
            .overlay(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                IconButton(icon: .arrowLeft){
                    dismiss()
                    mainRouter.hiddenTabView = false
                }
                .padding(.leading)
            }
    }
}
