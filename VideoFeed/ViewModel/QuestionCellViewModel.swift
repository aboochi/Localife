//
//  QuestionCellViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//



import Foundation
import FirebaseFirestore

@MainActor
final class QuestionCellViewModel: ObservableObject{
    
    @Published var replies: [Question] = []
    @Published var question: Question
    var lastDocument: DocumentSnapshot?
    @Published var didLike: Bool = false
    @Published var replyDidLike: [String: Bool] = [:]
    @Published var likeOffset: [String: Int]
    @Published var questionCellHeight: [String: CGFloat] = [:]
    
    @Published var questionlikerIds: [String] = []
    var lastDocumentQuestionLikers: DocumentSnapshot?
    @Published var replylikerIds: [String] = []
    var lastDocumentReplyLikers: DocumentSnapshot?
    
    let currentUser: DBUser
    
    init(question: Question, currentUser: DBUser){
        self.question = question
        self.currentUser = currentUser
        self.likeOffset = [question.id: 0]
        Task{
            
            try await checkQuestionLike(uid: currentUser.id)
        }
    }
    
    
    func fetchReplies() async throws {
        if replies.count > 0 && lastDocument == nil { return }
        let fetchRepliesResult = try await ListingManager.shared.getReplies(listingId: question.listingId, questionId: question.id, count: 5, lastDocument: lastDocument)
        lastDocument = fetchRepliesResult.lastDocument
        try await fetchAndsetQuestionOwner(fetchedReplies: fetchRepliesResult.output)
    }
    
    
    
    
    func fetchAndsetQuestionOwner(fetchedReplies: [Question]) async throws{
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
    
    func likeQuestion(uid: String) async throws {
        try await ListingManager.shared.likeQuestion(listingId: question.listingId, questionId: question.id, uid: uid)
        
        let category = NotificationCategoryEnum.questionLike.rawValue
        let notitificationId = question.listingId + question.id + category
        let notification = NotificationObject(id: notitificationId, targetId: question.questionOwnerId, category: category , userIds: [currentUser.id] , usernames: [currentUser.username ?? "unknown"], userPhotoUrls: [currentUser.photoUrl ?? "empty"], postId: question.listingId, postThumbnail: question.listingThumbnail, text: question.content, commentId: question.id, parentId: question.listingOwnerId, parentUsername: question.listingOwnerusername)
        try await NotificationManager.shared.saveNotification( notification: notification)
    }
    
    func unlikeQuestion(uid: String) async throws {
        try await ListingManager.shared.unlikeQuestion(listingId: question.listingId, questionId: question.id, uid: uid)
        
        let category = NotificationCategoryEnum.questionLike.rawValue
        let notitificationId = question.listingId + question.id + category
        try await NotificationManager.shared.removeNotification(userId: currentUser.id, targetId: question.questionOwnerId, notificationId: notitificationId)


    }
    
    func likeReply(reply: Question) async throws {
        try await ListingManager.shared.likeReply(listingId: question.listingId, questionId: question.id, replyId: reply.id, uid: currentUser.id)
        
        let category = NotificationCategoryEnum.questionReplyLike.rawValue
        let notitificationId = question.listingId + question.id + reply.id + category
        let notification = NotificationObject(id: notitificationId, targetId: reply.questionOwnerId, category: category , userIds: [currentUser.id], usernames: [currentUser.username ?? "unknown"], userPhotoUrls: [currentUser.photoUrl ?? "empty"], postId: question.listingId, postThumbnail: question.listingThumbnail, text: reply.content, commentId: question.id, replyId: reply.id, parentId: question.listingOwnerId, parentUsername: reply.listingOwnerusername)
        try await NotificationManager.shared.saveNotification( notification: notification)
    }
    
    
    func unlikeReply(reply: Question) async throws {
        
        
        try await ListingManager.shared.unlikeReply(listingId: question.listingId, questionId: question.id, replyId: reply.id, uid: currentUser.id)
        let category = NotificationCategoryEnum.questionReplyLike.rawValue
        let notitificationId = question.listingId + question.id + reply.id + category
        try await NotificationManager.shared.removeNotification(userId: currentUser.id, targetId: reply.questionOwnerId, notificationId: notitificationId)

    }
    
    func checkQuestionLike(uid: String) async throws {
        do{
            let result = try await ListingManager.shared.checkQuestionLike(listingId: question.listingId, questionId: question.id, uid: currentUser.id)
            self.didLike = result
        } catch {
            throw error
        }
    }
    
    func checkReplyLike(reply: Question) async throws -> Bool{
        do{
            let result = try await ListingManager.shared.checkReplyLike(listingId: question.listingId, questionId: question.id, replyId: reply.id, uid: currentUser.id)
            return result
        } catch {
            throw error
        }
    }
    
    
    
    func deleteReply(reply: Question) async throws {
        
        do{
            try await ListingManager.shared.removeReply(listingId: question.listingId, questionId: question.id, replyId: reply.id)
            
            let notificationCategory = question.parentQuestionId == nil ? NotificationCategoryEnum.questionReply.rawValue : NotificationCategoryEnum.questionMention.rawValue
            let notificationId = (reply.listingId)+(notificationCategory)+question.id+currentUser.id+timestampToString(timestamp: reply.time)
            try await NotificationManager.shared.removeNotification(userId: currentUser.id, targetId: reply.questionOwnerId, notificationId: notificationId)
        }catch{
            return
        }

        
    }
    
    
    
    func getReply(replyId: String) async throws -> Question{
        return try await ListingManager.shared.getReply(listingId: question.listingId, questionId: question.id, replyId: replyId)
    }
    
    func getQuestion(question: Question) async throws -> Question{
        return try await ListingManager.shared.getQuestion(listingId: question.listingId, questionId: question.id)
    }
    
    func getQuestionLikers() async throws {
        if questionlikerIds.count > 0 && lastDocumentQuestionLikers == nil{ return }
        let results = try await ListingManager.shared.getQuestionLikersIdByTime(listingId: question.listingId, questionId: question.id, count: 10, lastDocument: lastDocumentQuestionLikers)
        lastDocumentQuestionLikers = results.lastDocument
        questionlikerIds.append(contentsOf: results.output)
    }
    
    func getReplyLikers(replyId: String) async throws {
        if replylikerIds.count > 0 && lastDocumentReplyLikers == nil{ return }
        let results = try await ListingManager.shared.getReplyLikersIdByTime(listingId: question.listingId, questionId: question.id, replyId: replyId, count: 10, lastDocument: lastDocumentReplyLikers)
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

