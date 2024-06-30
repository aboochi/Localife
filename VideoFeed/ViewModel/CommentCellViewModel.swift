//
//  CommentCellViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/5/24.
//

import Foundation
import FirebaseFirestore

@MainActor
final class CommentCellViewModel: ObservableObject{
    
    @Published var replies: [Comment] = []
    @Published var comment: Comment
    var lastDocument: DocumentSnapshot?
    @Published var didLike: Bool = false
    @Published var replyDidLike: [String: Bool] = [:]
    @Published var likeOffset: [String: Int]
    @Published var commentCellHeight: [String: CGFloat] = [:]
    
    @Published var commentlikerIds: [String] = []
    var lastDocumentCommentLikers: DocumentSnapshot?
    @Published var replylikerIds: [String] = []
    var lastDocumentReplyLikers: DocumentSnapshot?
    
    let currentUser: DBUser
    
    init(comment: Comment, currentUser: DBUser){
        self.comment = comment
        self.currentUser = currentUser
        self.likeOffset = [comment.id: 0]
        Task{
            
            try await checkCommentLike(uid: currentUser.id)
        }
    }
    
    
    func fetchReplies() async throws {
        if replies.count > 0 && lastDocument == nil { return }
        let fetchRepliesResult = try await PostManager.shared.getReplies(postId: comment.postId, commentId: comment.id, count: 5, lastDocument: lastDocument)
        lastDocument = fetchRepliesResult.lastDocument
        try await fetchAndsetCommentOwner(fetchedReplies: fetchRepliesResult.output)
    }
    
    
    
    
    func fetchAndsetCommentOwner(fetchedReplies: [Comment]) async throws{
        for var reply in fetchedReplies{
            likeOffset[reply.id] = 0

            do{
                //get updated reply's user info
                try await reply.setUserOwner()
                
                //get updated mentioned's username
                if let mentionId = reply.mentionId{
                    try await reply.updateMentionUsername(mentionId: mentionId)
                }
                
                replyDidLike[reply.id] = try await checkReplyLike(reply: reply)
                
                self.replies.append(reply)
              
            } catch{
                replyDidLike[reply.id] = false
                self.replies.append(reply)

            }
            
        }
    }
    
    func likeComment(uid: String) async throws {
        try await PostManager.shared.likeComment(postId: comment.postId, commentId: comment.id, uid: uid)
        
        let category = NotificationCategoryEnum.commentLike.rawValue
        let notitificationId = comment.postId + comment.id + category
        let notification = NotificationObject(id: notitificationId, targetId: comment.commentOwnerId, category: category , userIds: [currentUser.id], usernames: [currentUser.username ?? "unknown"], userPhotoUrls: [currentUser.photoUrl ?? "empty"], postId: comment.postId, postThumbnail: comment.postThumbnail, text: comment.content, commentId: comment.id, parentId: comment.postOwnerId, parentUsername: comment.postOwnerusername)
        try await NotificationManager.shared.saveNotification( notification: notification)
    }
    
    func unlikeComment(uid: String) async throws {
        try await PostManager.shared.unlikeComment(postId: comment.postId, commentId: comment.id, uid: uid)
        
        let category = NotificationCategoryEnum.commentLike.rawValue
        let notitificationId = comment.postId + comment.id + category
        try await NotificationManager.shared.removeNotification(userId: currentUser.id,  targetId: comment.commentOwnerId, notificationId: notitificationId )
    }
    
    func likeReply(reply: Comment) async throws {
        try await PostManager.shared.likeReply(postId: comment.postId, commentId: comment.id, replyId: reply.id, uid: currentUser.id)
        
        let category = NotificationCategoryEnum.replyLike.rawValue
        let notitificationId = comment.postId + comment.id + reply.id + category
        let notification = NotificationObject(id: notitificationId, targetId: reply.commentOwnerId, category: category , userIds: [currentUser.id], usernames: [currentUser.username ?? "unknown"], userPhotoUrls: [currentUser.photoUrl ?? "empty"], postId: comment.postId, postThumbnail: comment.postThumbnail, text: reply.content, commentId: comment.id, replyId: reply.id, parentId: comment.postOwnerId, parentUsername: reply.postOwnerusername)
        try await NotificationManager.shared.saveNotification( notification: notification)
    }
    
    
    func unlikeReply( reply: Comment) async throws {
        try await PostManager.shared.unlikeReply(postId: comment.postId, commentId: comment.id, replyId: reply.id, uid: currentUser.id)
        
        let category = NotificationCategoryEnum.replyLike.rawValue
        let notitificationId = comment.postId + comment.id + reply.id + category
        try await NotificationManager.shared.removeNotification(userId: currentUser.id,  targetId: comment.commentOwnerId, notificationId: notitificationId )
    }
    
    func checkCommentLike(uid: String) async throws {
        do{
            let result = try await PostManager.shared.checkCommentLike(postId: comment.postId, commentId: comment.id, uid: currentUser.id)
            self.didLike = result
        } catch {
            throw error
        }
    }
    
    func checkReplyLike(reply: Comment) async throws -> Bool{
        do{
            let result = try await PostManager.shared.checkReplyLike(postId: comment.postId, commentId: comment.id, replyId: reply.id, uid: currentUser.id)
            return result
        } catch {
            throw error
        }
    }
    
    
    
    func deleteReply(reply: Comment) async throws {
        try await PostManager.shared.removeReply(postId: comment.postId, commentId: comment.id, replyId: reply.id)
        
        
       
        let notificationCategory = comment.parentCommentId == nil ? NotificationCategoryEnum.postReply.rawValue : NotificationCategoryEnum.commentMention.rawValue
        let notitificationId = (comment.postId)+(notificationCategory)+comment.id+currentUser.id+timestampToString(timestamp: reply.time)
        let commentId = comment.parentCommentId == nil ? comment.id : comment.parentCommentId
        try await NotificationManager.shared.removeNotification(userId: currentUser.id,  targetId: comment.commentOwnerId, notificationId: notitificationId )

    }
    
    
    
    func getReply(replyId: String) async throws -> Comment{
        return try await PostManager.shared.getReply(postId: comment.postId, commentId: comment.id, replyId: replyId)
    }
    
    func getComment(comment: Comment) async throws -> Comment{
        return try await PostManager.shared.getcomment(postId: comment.postId, commentId: comment.id)
    }
    
    func getCommentLikers() async throws {
        if commentlikerIds.count > 0 && lastDocumentCommentLikers == nil{ return }
        let results = try await PostManager.shared.getCommentLikersIdByTime(postId: comment.postId, commentId: comment.id, count: 10, lastDocument: lastDocumentCommentLikers)
        lastDocumentCommentLikers = results.lastDocument
        commentlikerIds.append(contentsOf: results.output)
    }
    
    func getReplyLikers() async throws {
        if replylikerIds.count > 0 && lastDocumentReplyLikers == nil{ return }
        let results = try await PostManager.shared.getCommentLikersIdByTime(postId: comment.postId, commentId: comment.id, count: 10, lastDocument: lastDocumentReplyLikers)
        lastDocumentReplyLikers = results.lastDocument
        replylikerIds.append(contentsOf: results.output)
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
