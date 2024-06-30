//
//  CommentViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/3/24.
//

import SwiftUI
import FirebaseFirestore


@MainActor
class CommentsViewModel: ObservableObject {
    
    let post: Post
    var lastDocument: DocumentSnapshot?

    
    
    @Published var comments = [Comment]()
    
    init(post: Post) {
        self.post = post
        Task{
            try await fetchComments()
        }
    }
    
    func fetchComments() async throws {
        let fetchedComments =  try await PostManager.shared.getComments(postId: post.id , lastDocument: lastDocument)
        try await fetchAndsetCommentOwner(fetchedComments: fetchedComments.output)

    }
    
    func addComment(content: String, user: DBUser) async throws {
        let id = UUID().uuidString
        guard let username = user.username else {return}
        var comment = Comment(id: id, commentOwnerId: user.id, username: username, post: post, content: content)
        try await PostManager.shared.addComment(postId: post.id, comment: comment)
        comment.setUserOwner(user: user)
        comments.append(comment)
        
        let notificationId = (post.id)+(NotificationCategoryEnum.postComment.rawValue)+user.id+timestampToString(timestamp: comment.time)
        let notification = NotificationObject(id: notificationId, targetId: post.ownerUid, category: NotificationCategoryEnum.postComment.rawValue, userIds: [user.id], usernames: [user.username ?? "unknown"] , userPhotoUrls: [user.photoUrl ?? "empty"], postId: post.id, postThumbnail: comment.postThumbnail, text: content, parentId: post.user?.id, parentUsername: post.user?.username)
        try await NotificationManager.shared.saveNotification( notification: notification)
        
    }
    
    
    func replyToComment(content: String, user: DBUser, comment: Comment) async throws -> Comment{
        guard let username = user.username else { throw URLError(.badServerResponse) }
            do{
                let id = UUID().uuidString
                var reply = Comment(id: id, commentOwnerId: user.id, username: username , post: post, content: content, comment: comment)
                try await PostManager.shared.replyToComment(postId: post.id, commentId: comment.id, comment: reply)
                reply.setUserOwner(user: user)
                
                
                let notificationCategory = comment.parentCommentId == nil ? NotificationCategoryEnum.postReply.rawValue : NotificationCategoryEnum.commentMention.rawValue
                let notificationId = (post.id)+(notificationCategory)+comment.id+user.id+timestampToString(timestamp: reply.time)
                let commentId = comment.parentCommentId == nil ? comment.id : comment.parentCommentId
                let notification = NotificationObject(id: notificationId, targetId: comment.commentOwnerId, category: notificationCategory, userIds: [user.id], usernames: [user.username ?? "unknown"] , userPhotoUrls: [user.photoUrl ?? "empty"], postId: post.id, postThumbnail: comment.postThumbnail, text: content,  commentId:  commentId, replyId: comment.id , parentId: post.user?.id, parentUsername: post.user?.username)
                try await NotificationManager.shared.saveNotification( notification: notification)
                
                
                return reply
            }
        
    }
    
    func deleteComment(comment: Comment , user: DBUser) async throws {
        try await PostManager.shared.removeComment(postId: comment.postId, commentId: comment.id)
        
        let notificationId = (post.id)+(NotificationCategoryEnum.postComment.rawValue)+user.id+timestampToString(timestamp: comment.time)
        try await NotificationManager.shared.removeNotification(userId: user.id, targetId: post.ownerUid, notificationId: notificationId)
    }
    
   
    
    func fetchAndsetCommentOwner(fetchedComments: [Comment]) async throws{
        for var comment in fetchedComments{
            do{
                try await comment.setUserOwner()
                
                self.comments.append(comment)
                
            } catch{
                
                self.comments.append(comment)

            }
        }
    }
    
    func editComment(comment: Comment, content: String) async throws {
        try await PostManager.shared.editComment(postId: comment.postId, commentId: comment.id, content: content)
    }
    
    func editReply(comment: Comment, content: String) async throws {
        guard let commentId = comment.parentCommentId else { return}
        try await PostManager.shared.editReply(postId: comment.postId, commentId: commentId, replyId: comment.id, content: content)
    }
    
    func getComment(comment: Comment) async throws -> Comment{
        return try await PostManager.shared.getcomment(postId: comment.postId, commentId: comment.id)
    }
    
    
    func timestampToString(timestamp: Timestamp) -> String {
        // Convert Timestamp to Date
        let date = timestamp.dateValue()
        
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        // Set the date format you want
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Convert Date to String
        return dateFormatter.string(from: date)
    }
    
}
