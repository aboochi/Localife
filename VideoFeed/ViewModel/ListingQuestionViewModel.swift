//
//  ListingQuestionViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//



import SwiftUI
import FirebaseFirestore


@MainActor
class ListingQuestionViewModel: ObservableObject {
    
    let listing: Listing
    var lastDocument: DocumentSnapshot?

    
    
    @Published var questions = [Question]()
    
    init(listing: Listing) {
        self.listing = listing
        Task{
            try await fetchQuestions()
        }
    }
    
    func fetchQuestions() async throws {
        
        if questions.count > 0 && lastDocument == nil { return }
        let fetchedQuestions =  try await  ListingManager.shared.getQuestions(listingId: listing.id, lastDocument: lastDocument)
        try await fetchAndsetQuestionOwner(fetchedQuestions: fetchedQuestions.output)
        lastDocument = fetchedQuestions.lastDocument
        
       

    }
    
    func addQuestion(content: String, user: DBUser) async throws {
        let id = UUID().uuidString
        guard let username = user.username else {return}
        var question = Question(id: id, questionOwnerId: user.id, username: username, listing: listing, content: content)
        try await ListingManager.shared.addQuestion(listingId: listing.id, question: question)
        question.setUserOwner(user: user)
        questions.append(question)
        
        let notificationId = (listing.id)+(NotificationCategoryEnum.listingQuestion.rawValue)+user.id+timestampToString(timestamp: question.time)
        let notification = NotificationObject(id: notificationId, targetId: listing.ownerUid, category: NotificationCategoryEnum.listingQuestion.rawValue, userIds: [user.id], usernames: [user.username ?? "unknown"] , userPhotoUrls: [user.photoUrl ?? "empty"], postId: listing.id, postThumbnail: question.listingThumbnail, text: content, parentId: listing.user?.id, parentUsername: listing.user?.username)
        try await NotificationManager.shared.saveNotification( notification: notification)
        
    }
    
    
    func replyToQuestion(content: String, user: DBUser, question: Question) async throws -> Question{
        guard let username = user.username else { throw URLError(.badServerResponse) }
            do{
                let id = UUID().uuidString
                var reply = Question(id: id, questionOwnerId: user.id, username: username , listing: listing, content: content, question: question)
                try await ListingManager.shared.replyToQuestion(listingId: listing.id, questionId: question.id, reply: reply)
                reply.setUserOwner(user: user)
                
                
                let notificationCategory = question.parentQuestionId == nil ? NotificationCategoryEnum.questionReply.rawValue : NotificationCategoryEnum.questionMention.rawValue
                let notificationId = (listing.id)+(notificationCategory)+question.id+user.id+timestampToString(timestamp: reply.time)
                let questionId = question.parentQuestionId == nil ? question.id : question.parentQuestionId
                let notification = NotificationObject(id: notificationId, targetId: question.questionOwnerId, category: notificationCategory, userIds: [user.id], usernames: [user.username ?? "unknown"] , userPhotoUrls: [user.photoUrl ?? "empty"], postId: listing.id, postThumbnail: question.listingThumbnail, text: content,  commentId:  questionId, replyId: question.id , parentId: listing.user?.id, parentUsername: listing.user?.username)
                try await NotificationManager.shared.saveNotification( notification: notification)
                
                
                return reply
            }
        
    }
    
    func deleteQuestion(question: Question , user: DBUser) async throws {
        
        do{
            try await ListingManager.shared.removeQuestion(listingId: question.listingId, questionId: question.id)
            
            let notificationId = (listing.id)+(NotificationCategoryEnum.listingQuestion.rawValue)+user.id+timestampToString(timestamp: question.time)
            try await NotificationManager.shared.removeNotification(userId: user.id, targetId: listing.ownerUid, notificationId: notificationId)
        }catch{
            return
        }
    }
    
   
    
    func fetchAndsetQuestionOwner(fetchedQuestions: [Question]) async throws{
        for var question in fetchedQuestions{
            do{
                try await question.setUserOwner()
                
                self.questions.append(question)
                
            } catch{
                
                //self.questions.append(question)

            }
        }
    }
    
    func editQuestion(question: Question, content: String) async throws {
        try await ListingManager.shared.editQuestion(listingId: question.listingId, questionId: question.id, content: content)
    }
    
    func editReply(question: Question, content: String) async throws {
        guard let questionId = question.parentQuestionId else { return }
        try await ListingManager.shared.editReply(listingId: question.listingId, questionId: questionId, replyId: question.id, content: content)
    }
    
    func getQuestion(question: Question) async throws -> Question{
        return try await ListingManager.shared.getQuestion(listingId: question.listingId, questionId: question.id)
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

