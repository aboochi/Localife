//
//  CommentView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/3/24.
//

import SwiftUI
import SwipeActions

enum CommentActionType{
    case reply
    case delete
    case edit
    case report
    case noAction
}

struct CommentsView: View {
    
    @State var commentText = ""
    @ObservedObject var viewModel: CommentsViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @State var bufferComment: Comment?
    @State var replySent: Bool = false
    @State var actionOrder: CommentActionType = .noAction
    @State var state: SwipeState = .untouched
    @Binding var  showCaption: Bool
    @FocusState private var focus: FocusableField?
    @State var path = NavigationPath()


    
    init(post: Post, showCaption: Binding<Bool>) {
        self.viewModel = CommentsViewModel(post: post)
        self._showCaption = showCaption
    }
    
    var body: some View {
        
        ZStack{
            NavigationStack(path: $path){
                VStack() {
                    Text("Comments")
                        .font(.system(size: 20, weight: .medium))
                        .padding(.top, 10)
                    Divider()
                    ScrollView {
                        
                        
                        if showCaption{
                            HStack(alignment: .top){
                                AvatarView(photoUrl: viewModel.post.user?.photoUrl, username: viewModel.post.user?.username, size: 36)
                                VStack(alignment: .leading, spacing: 4){
                                    HStack(spacing: 5){
                                        Text(viewModel.post.user?.username ?? "Caption")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        Text( TimeFormatter.shared.timeAgoFormatter(time:  viewModel.post.time))
                                            .font(.system(size: 14, weight: .light))
                                            .foregroundColor(.gray)
                                        
                                        
                                    }
                                    
                                    Text(viewModel.post.caption)
                                        .font(.system(size: 14))
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            Divider()
                            
                        }
                        
                        
                        
                        LazyVStack(alignment: .leading, spacing: 24) {
                            ForEach(viewModel.comments){ comment in
                                CommentsCellView(viewModel: CommentCellViewModel(comment: comment, currentUser: session.dbUser), bufferComment: $bufferComment, actionOrder: $actionOrder, replySent: $replySent, state: $state, postOwnerUsername: viewModel.post.user?.username ?? "unknown", path: $path)
                            }
                        }
                    }
                    if let comment = bufferComment , (actionOrder == .reply || actionOrder == .edit){
                        Divider()
                        HStack{
                            if actionOrder == .reply{
                                Text("Replying to @\(comment.user?.username ?? "Deleted Account")")
                                    .foregroundColor(.black)
                            } else {
                                let description = (comment.parentCommentId == nil) ? "comment" : "reply"
                                Text("Editing your \(description)")
                                    .foregroundColor(.black)
                                    .onAppear{
                                        commentText = comment.content
                                    }
                            }
                            
                            Spacer()
                            Button(action: {
                                bufferComment = nil
                                actionOrder = .noAction
                                commentText = ""
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                
                                
                            })
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    
                    commentIput()
                }
                
                .modifier(Navigationmodifier(path: $path))

                
                .onTapGesture {
                    focus = nil
                }
                
                
                .onChange(of: actionOrder) { oldValue, newValue in
                    if oldValue == .noAction && newValue == .delete {
                        if let comment = bufferComment {
                            Task{
                                try await viewModel.deleteComment(comment: comment, user: session.dbUser)
                                if let index = viewModel.comments.firstIndex(where: {$0.id == comment.id}){
                                    viewModel.comments.remove(at: index)
                                }
                                bufferComment = nil
                                actionOrder = .noAction
                            }
                        }
                    }
                }
            }
            
            if viewModel.comments.count < 1{
                
                VStack{
                    
                    Text("No comments yet")
                    
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(10)
                    
                    Text("Be the first one")
                        .font(.system(size: 14, weight: .light))
                            .foregroundColor(.black)
                    
                    
                }
            }
            
        }
    }
    
    func uploadComment() async throws {
        let user = session.dbUser
        try await viewModel.addComment(content: commentText, user: user )
        self.commentText = ""
    }
    
    func uploadReply(comment: Comment) async throws {
        do{
            let user = session.dbUser
            let reply = try await viewModel.replyToComment(content: commentText, user: user, comment: comment)
            self.commentText = ""
            self.bufferComment = reply
            self.replySent = true
        } catch {
            bufferComment = nil
            print("failed to send reply")
            throw error
        }
        
    }
    
    
    func commentIput() -> some View{
        
        
            VStack {
                Rectangle()
                    .foregroundColor(Color(.separator))
                    .frame(width: UIScreen.main.bounds.width, height: 0.8)
                
                HStack {
                    
                    
                    TextField("Comment...", text: $commentText)
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 45)
                        .background(Capsule().fill(Color.white.opacity(0.3)))
                        .overlay(
                            Capsule()
                                .stroke(.gray, lineWidth: 1)
                        )
                        
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focus, equals: .username)
                        .submitLabel(.send)
                        .onSubmit {
                            commentAction()
                        }
                    
                 
                    Button {
                        
                        commentAction()
                        
     
                    } label: {
                        Text("Send")
                            .bold()
                            .foregroundColor(.black)
                    }

              
                  
                }.padding(.horizontal)
                
            }.padding(.bottom, 8)
        }
    
    
    func commentAction(){
        
        
        
        Task{
            if let comment = bufferComment, actionOrder == .reply{
                try await uploadReply(comment: comment)
                
            }else if let comment = bufferComment, actionOrder == .edit{
                if comment.parentCommentId == nil{
                    Task{
                        try await viewModel.editComment(comment: comment, content: commentText)
                        
                        actionOrder = .noAction
                        commentText = ""
                    }
                } else{
                    Task{
                        try await viewModel.editReply(comment: comment, content: commentText)
                        
                        actionOrder = .noAction
                        commentText = ""
//                                        let updatedComment = try await viewModel.getComment(comment: comment)
//                                        if let index = viewModel.comments.firstIndex(where: {$0.id == comment.id}){
//                                            viewModel.comments[index].content = updatedComment.content
//                                        }
                       


                    }
                }
                
            }else{
                Task{
                    try await uploadComment()
                }
            }
        }
    }
    
    
    
}
