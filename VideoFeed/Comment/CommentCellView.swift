//
//  CommentCellView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/3/24.
//

import SwiftUI
import Kingfisher
import SwipeActions

struct CommentsCellView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @StateObject var viewModel: CommentCellViewModel
    @Binding var bufferComment: Comment?
    @Binding var actionOrder: CommentActionType
    @Binding var replySent: Bool
    @Binding var state: SwipeState
    let postOwnerUsername: String
    @State var updatedCommentContent: String?
    @State var actionOrderLikersList: FollowActionOrder = .none
    @Binding var path: NavigationPath

    

    
    var body: some View {
        
            
            VStack(alignment: .leading){
                singleCommentDisplay(comment: viewModel.comment)
                    .background(
                        GeometryReader { proxy in
                            Color.clear // we just want the reader to get triggered, so let's use an empty color
                                .onAppear {
                                    viewModel.commentCellHeight[viewModel.comment.id] = proxy.size.height
                                }
                        }
                    )
                
                    .addSwipeAction(edge: .trailing,  state : $state){
                        SwipeActionButtons(comment: viewModel.comment)
                    }
                
                
                VStack(alignment: .leading){
                    ForEach(viewModel.replies, id: \.id){ reply in
                        
                        singleCommentDisplay(comment: reply)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                                        .onAppear {
                                            viewModel.commentCellHeight[reply.id] = proxy.size.height
                                        }
                                }
                            )
                            .addSwipeAction(edge: .trailing, state : $state){
                                SwipeActionButtons(comment: reply)
                            }
                        
                        
                    }
                }
                .padding(.leading, 43)
                .onChange(of: state) { oldValue, newValue in
                   
                    
                }
                
                
                
                if  viewModel.comment.replyNumber  - viewModel.replies.count > 0 &&  viewModel.replies.count > 0{
                    Button(action: {
                        Task{
                            try await viewModel.fetchReplies()
                        }
                    }, label: {
                        Text("View \(viewModel.comment.replyNumber - viewModel.replies.count) replies")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    })
                    .padding(.leading, 60)
                    
                }
            }
            
            
            
            .onChange(of: replySent) { oldValue, newValue in
                
                if let reply = bufferComment,  reply.parentCommentId == viewModel.comment.id , newValue == true {
                    viewModel.replyDidLike[reply.id] = false
                    viewModel.likeOffset[reply.id] = 0
                    viewModel.replies.append(reply)
                    bufferComment = nil
                    replySent = false
                    print("viewModel.replies : \(viewModel.replies)")
                    
                }
            }
            
            .onChange(of: actionOrder) { oldValue, newValue in
                if oldValue == .edit && newValue  == .noAction{
                    
                    if let comment = bufferComment , let _ = comment.parentCommentId  {
                        Task{
                            let updatedComment = try await viewModel.getReply(replyId: comment.id)
                            if let index = viewModel.replies.firstIndex(where: {$0.id == updatedComment.id}){
                                viewModel.replies[index].content = updatedComment.content
                            }
                            bufferComment = nil
                        }
                    } else if let comment = bufferComment, comment.id == viewModel.comment.id{
                        
                        Task{
                            let updatedComment = try await viewModel.getComment(comment: comment)
                            
                            updatedCommentContent = updatedComment.content
                            
                        }
                        
                        bufferComment = nil
                        
                    }
                }
            }
            
            
            
            .onChange(of: actionOrderLikersList) { oldValue, newValue in
                if newValue == .fetch {
                    Task{
                        try await viewModel.getCommentLikers()
                    }
                }
            }
     
    }
    
    
    @ViewBuilder
    func singleCommentDisplay(comment: Comment) -> some View {
        HStack (alignment: .top) {
            
            
                AvatarView(photoUrl: comment.user?.photoUrl, username: comment.user?.username, size: 35)
                    .onTapGesture {
                        if let user = comment.user{
                            let value = NavigationValuegeneral(type: .profile, user: user)
                            path.append(value)
                        }
                    }
            

        
            VStack (alignment: .leading){
                HStack(alignment: .center) {
                    Text(comment.user?.username ?? comment.commentOwnerUsername)
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text(comment.timestampText ?? "")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                        .padding(.trailing)
                    
                  
                        
                    
                }
              //  .padding(.bottom, 0.5)
                
                if let mention = comment.mentionUsername{
                    
                        
                        Text("@\(mention) ")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                           
                    
                        + Text("\(comment.content)")
                            .font(.system(size: 14))
                    
                   
                    
                } else {
                    Text("\(updatedCommentContent == nil ? comment.content: updatedCommentContent ?? comment.content)")
                    
                        .font(.system(size: 14))
                }
                
                HStack(spacing: 10){
                    replyButtion(comment: comment)
                    numberOfLike(comment: comment)
                    likeButton(comment: comment)
                }
                
                
                
                if comment.parentCommentId == nil && viewModel.comment.replyNumber  > 0 && viewModel.replies.count == 0{
                    Button(action: {
                        Task{
                            try await viewModel.fetchReplies()
                        }
                    }, label: {
                        Text("View \(viewModel.comment.replyNumber - viewModel.replies.count) replies")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.top, 1)
                    })
                    
                            
                        }
   
            }
     
                Spacer()
                
               
            
            
        }.padding(.horizontal)
            
    }
    
    
    
    
    @ViewBuilder
    func replyButtion(comment: Comment) -> some View{
        
        Button(action: {
            if comment.commentOwnerId == viewModel.comment.parentCommentId{
                bufferComment = comment
            }else{
                var newComment = viewModel.comment
                newComment.setOwnerId(siblingCommentId: comment.commentOwnerId)
                newComment.setOwnerUsername(siblingCommentUsername: comment.commentOwnerUsername)
                newComment.setUserOwner(user: comment.user)
                newComment.parentCommentId = comment.parentCommentId
                bufferComment = newComment
                actionOrder = .reply

            }

            
        }, label: {
            Text("Reply")
                
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.top, 1)
        })
    }
    
    @ViewBuilder
    func numberOfLike(comment: Comment) -> some View{
        let like = comment.likeNumber +  (viewModel.likeOffset[comment.id] ?? 0)
        if like > 0{
            
            
            
                Text("\(like) \(like > 1 ? "Likes" : "Like")")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                    .padding(.top, 1)
                    .onTapGesture {
                        let value = NavigationValuegeneral(type: .commentLiker, comment: comment)
                        path.append(value)
                    }
            

        }
    }
    
    @ViewBuilder
    func likeButton(comment: Comment) -> some View{
        
        Button(action: {
            if comment.parentCommentId == nil{
                if viewModel.didLike{
                    viewModel.didLike = false
                    if let offset = viewModel.likeOffset[comment.id]{
                        viewModel.likeOffset[comment.id] = offset - 1
                    }
                    
                    Task{
                        try await viewModel.unlikeComment(uid: session.dbUser.id)
                    }
                }else {
                    viewModel.didLike = true
                    if let offset = viewModel.likeOffset[comment.id]{
                        viewModel.likeOffset[comment.id] = offset + 1
                    }

                    Task{
                        try await viewModel.likeComment(uid: session.dbUser.id)
                    }
                }
            } else {
                if let didLike = viewModel.replyDidLike[comment.id], didLike == true{
                    viewModel.replyDidLike[comment.id] = false
                    if let offset = viewModel.likeOffset[comment.id]{
                        viewModel.likeOffset[comment.id] = offset - 1
                    }

                    Task{
                        try await viewModel.unlikeReply(reply: comment)
                    }
                } else {
                    viewModel.replyDidLike[comment.id] = true
                    if let offset = viewModel.likeOffset[comment.id]{
                        viewModel.likeOffset[comment.id] = offset + 1
                    }

                    Task{
                        try await viewModel.likeReply(reply: comment)
                    }
                }
            }
            
        }, label: {
            let didLike = comment.parentCommentId == nil ? viewModel.didLike : viewModel.replyDidLike[comment.id]
            Image(systemName: didLike! ? "heart.fill" : "heart")
                .font(.system(size: 14))
                .foregroundColor(didLike! ? .red : .gray)
                
            
           
                
        })
    }
    
    @ViewBuilder
    func SwipeActionButtons(comment: Comment) -> some View{
        
        if session.dbUser.id == comment.commentOwnerId || session.dbUser.id == comment.postOwnerId{
            
            Button {
                if comment.parentCommentId == nil {
                    bufferComment = comment
                    actionOrder = .delete
                } else{
                    Task{
                        try await viewModel.deleteReply(reply: comment)
                        if let index = viewModel.replies.firstIndex(where: {$0.id == comment.id}){
                            viewModel.replies.remove(at: index)
                        }
                        
                    }
                }
                print("remove")
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: viewModel.commentCellHeight[comment.id] ?? 60, alignment: .center)
            .contentShape(Rectangle())
            .background(Color.red)
            
        }
//        Button {
//            print("Inform")
//            state = .swiped(UUID(uuidString: comment.id)!)
//
//        } label: {
//            Image(systemName: "arrow.uturn.up")
//                .foregroundColor(.white)
//        }
//        .frame(width: 60, height: viewModel.commentCellHeight[comment.id] ?? 60, alignment: .center)
//        .background(Color.blue)
        
        if session.dbUser.id == comment.commentOwnerId{
            Button {
                bufferComment = comment
                actionOrder = .edit
                print("Edit")
                state = .swiped(UUID(uuidString: comment.id)!)
                
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: viewModel.commentCellHeight[comment.id] ?? 60, alignment: .center)
            .background(Color.gray)
        }
    }
}




