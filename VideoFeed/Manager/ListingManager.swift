//
//  ListingManager.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/9/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ListingManager{
    
    static let shared = ListingManager()
    private init() { }
    
    private let listingsCollection = Firestore.firestore().collection("Listings")
    private let listingCategoryCollection = Firestore.firestore().collection("ListingCategory")

    
    
    private func listingDocument(listingId: String) -> DocumentReference {
        listingsCollection.document(listingId)
    }
    
    private func listingCategoryDocument(uid: String) -> DocumentReference {
        listingCategoryCollection.document(uid)
    }
    
    
    private func listingInterestedCollection(listingId: String) ->  CollectionReference {
        listingDocument(listingId: listingId).collection("ListingInterested")
    }
    
    private func listingInterestedDocument(listingId: String, uid: String) -> DocumentReference {
        listingInterestedCollection(listingId: listingId).document(uid)
     
    }
    
    
    private func listingQuestionCollection(listingId: String) ->  CollectionReference {
        listingDocument(listingId: listingId).collection("ListingQuestion")
    }
    
    private func listingQuestionDocument(listingId: String, questionId: String) -> DocumentReference {
        listingQuestionCollection(listingId: listingId).document(questionId)
    }
    
    
    private func listingQuestionRepliesCollection(listingId: String, questionId: String) -> CollectionReference {
        listingQuestionDocument(listingId: listingId, questionId: questionId).collection("QuestionReplies")
    }
    
    private func listingQuestionRepliesDocument(listingId: String, questionId: String, replyId: String) -> DocumentReference {
        listingQuestionRepliesCollection(listingId: listingId, questionId: questionId).document(replyId)
    }
    
    private func listingQuestionLikesCollection(listingId: String, questionId: String) -> CollectionReference {
        listingQuestionDocument(listingId: listingId, questionId: questionId).collection("QuestionLikes")
    }
    
    private func listingQuestionLikesDocument(listingId: String, uid: String, questionId: String) -> DocumentReference {
        listingQuestionLikesCollection(listingId: listingId, questionId: questionId).document(uid)
    }
    
    private func listingQuestionReplyLikeCollection(listingId: String, questionId: String, replyId: String) -> CollectionReference{
        listingQuestionRepliesDocument(listingId: listingId, questionId: questionId, replyId: replyId).collection("ReplyLikes")
    }
    
    private func listingQuestionReplyLikeDocument(listingId: String, questionId: String, replyId: String, uid: String) -> DocumentReference{
        listingQuestionReplyLikeCollection(listingId: listingId, questionId: questionId, replyId: replyId).document(uid)
    }
    
    
    func setCategoryInterest(uid: String, categories: [String]) async throws {
        try await listingCategoryDocument(uid: uid).setData(["categories": categories])
    }
    
    func getCategories(uid: String) async throws -> [String]{
        try await listingCategoryDocument(uid: uid).getDocument(as: [String: [String]].self)["categories"] ?? []
    }
    
    func uploadListing(listing: Listing) async throws {
        try listingDocument(listingId: String(listing.id)).setData(from: listing, merge: false)
    }
    
    func getListing(listingId: String) async throws -> Listing {
        try await listingDocument(listingId: listingId).getDocument(as: Listing.self)
    }
    
    func removeListing(listingId: String) async throws  {
        try await listingDocument(listingId: listingId).delete()
    }
    
    func getListingsByTime(count: Int ,  lastDocument: DocumentSnapshot?) async throws -> (output: [Listing], lastDocument: DocumentSnapshot?) {
        if let lastDocument = lastDocument {
            return try await listingsCollection
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Listing.self)
        } else {
            return try await listingsCollection
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Listing.self)
        }
    }
    
    
    
    func getListingsByTimeAndCategory(count: Int,  categories: [String], lastDocument: DocumentSnapshot?) async throws -> (output: [Listing], lastDocument: DocumentSnapshot?) {
        guard categories.count > 0 else { throw URLError(.unknown)}
        if let lastDocument = lastDocument {
            return try await listingsCollection
              
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .whereField(Listing.CodingKeys.category.rawValue, in: categories) // Add the query for categories here
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Listing.self)
        } else {
            return try await listingsCollection
             
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .whereField(Listing.CodingKeys.category.rawValue, in: categories) // Add the query for categories here
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Listing.self)
        }
    }
    
    func getListingsActiveByTimeAndUid(count: Int, uid: String, lastDocument: DocumentSnapshot?) async throws -> (output: [Listing], lastDocument: DocumentSnapshot?) {
        let currentTimestamp = Timestamp() // Get the current timestamp

        if let lastDocument = lastDocument {
           
            return try await listingsCollection
                
                .whereField(Listing.CodingKeys.ownerUid.rawValue, isEqualTo: uid )
                .whereField(Listing.CodingKeys.validUntil.rawValue, isGreaterThan: currentTimestamp)
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .start(afterDocument: lastDocument)

                .getDocumentsWithSnapshot(as: Listing.self)
        } else {
           

            return try await listingsCollection
                .whereField(Listing.CodingKeys.ownerUid.rawValue, isEqualTo: uid )
                .whereField(Listing.CodingKeys.validUntil.rawValue, isGreaterThan: currentTimestamp)
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Listing.self)
        }
    }
    
    
    func getListingsActiveByTimeAndKeywords(count: Int, keywords: [String], lastDocument: DocumentSnapshot?) async throws -> (output: [Listing], lastDocument: DocumentSnapshot?) {
        let currentTimestamp = Timestamp() // Get the current timestamp

        if let lastDocument = lastDocument {
           
            return try await listingsCollection
                
                .whereField(Listing.CodingKeys.keywords.rawValue, arrayContainsAny: keywords )
                .whereField(Listing.CodingKeys.validUntil.rawValue, isGreaterThan: currentTimestamp)
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .start(afterDocument: lastDocument)

                .getDocumentsWithSnapshot(as: Listing.self)
        } else {
           

            return try await listingsCollection
                .whereField(Listing.CodingKeys.keywords.rawValue, arrayContainsAny: keywords )
                .whereField(Listing.CodingKeys.validUntil.rawValue, isGreaterThan: currentTimestamp)
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Listing.self)
        }
        
       

    }
    
    
    
    func getListingsExpiredByTimeAndUid(count: Int, uid: String, lastDocument: DocumentSnapshot?) async throws -> (output: [Listing], lastDocument: DocumentSnapshot?) {
        let currentTimestamp = Timestamp() 

        if let lastDocument = lastDocument {
            return try await listingsCollection
                
                .whereField(Listing.CodingKeys.ownerUid.rawValue, isEqualTo: uid )
                .whereField(Listing.CodingKeys.validUntil.rawValue, isLessThan: currentTimestamp)
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Listing.self)
        } else {
            return try await listingsCollection
                
                .whereField(Listing.CodingKeys.ownerUid.rawValue, isEqualTo: uid )
                .whereField(Listing.CodingKeys.validUntil.rawValue, isLessThan: currentTimestamp)
                .order(by: Listing.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Listing.self)
        }
    }
    
    func getListingById(listingId: String) async throws -> Listing {
        try await listingDocument(listingId: listingId).getDocument(as : Listing.self)

    }
    
    
    
    func addLike(listingId: String, uid: String) async throws {
        try await listingInterestedDocument(listingId: listingId, uid: uid).setData(["time": Timestamp(), "id": uid])
        try await listingDocument(listingId: listingId).updateData([Listing.CodingKeys.interestedNumber.rawValue : FieldValue.increment(1.0)])

    }
    
    
    func removeLike(listingId: String, uid: String) async throws {
        try await listingInterestedDocument(listingId: listingId, uid: uid).delete()
        try await listingDocument(listingId: listingId).updateData([Listing.CodingKeys.interestedNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    func checkListingLike(listingId: String, uid: String) async throws -> Bool {
        do{
            let doc = try await listingInterestedDocument(listingId: listingId, uid: uid).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
  
    func addQuestion(listingId: String, question: Question) async throws {
        
        try  listingQuestionDocument(listingId: listingId, questionId: question.id) .setData(from: question, merge: false)
        try await listingDocument(listingId: listingId).updateData([Listing.CodingKeys.questionNumber.rawValue : FieldValue.increment(1.0)])

    }
    
    
    func replyToQuestion(listingId: String, questionId: String, reply: Question) async throws {
        
        try listingQuestionRepliesDocument(listingId: listingId, questionId: questionId, replyId: reply.id).setData(from: reply, merge: false)
        try await listingQuestionDocument(listingId: listingId, questionId: questionId).updateData([Question.CodingKeys.replyNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func getReplies(listingId: String, questionId: String , count: Int = 5, lastDocument: DocumentSnapshot?) async throws -> (output: [Question] , lastDocument: DocumentSnapshot?){
        
        if let lastDocument = lastDocument {
            try await listingQuestionRepliesCollection(listingId: listingId, questionId: questionId)
                .order(by: Question.CodingKeys.time.rawValue, descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Question.self)
        } else {
            try await listingQuestionRepliesCollection(listingId: listingId, questionId: questionId)
                .order(by: Question.CodingKeys.time.rawValue, descending: false)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Question.self)
        }
            
    }
    
    
    func likeQuestion(listingId: String, questionId: String, uid: String) async throws {
        
        try await listingQuestionLikesDocument(listingId: listingId, uid: uid, questionId: questionId).setData(["time": Timestamp(), "uid": uid])
        try await listingQuestionDocument(listingId: listingId, questionId: questionId).updateData([Question.CodingKeys.likeNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func unlikeQuestion(listingId: String, questionId: String, uid: String) async throws {
        
        try  await listingQuestionLikesDocument(listingId: listingId, uid: uid, questionId: questionId).delete()
        try await listingQuestionDocument(listingId: listingId, questionId: questionId).updateData([Question.CodingKeys.likeNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    func checkQuestionLike(listingId: String, questionId: String, uid: String) async throws -> Bool {
        do{
            let doc = try  await listingQuestionLikesDocument(listingId: listingId, uid: uid, questionId: questionId).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
    func likeReply(listingId: String, questionId: String, replyId: String, uid: String) async throws{
        try await listingQuestionReplyLikeDocument(listingId: listingId, questionId: questionId, replyId: replyId, uid: uid).setData(["time": Timestamp(), "uid": uid])
        try await listingQuestionRepliesDocument(listingId: listingId, questionId: questionId, replyId: replyId).updateData([Question.CodingKeys.likeNumber.rawValue : FieldValue.increment(1.0)])

    }
    
    func unlikeReply(listingId: String, questionId: String, replyId: String, uid: String) async throws{
        try await listingQuestionReplyLikeDocument(listingId: listingId, questionId: questionId, replyId: replyId, uid: uid).delete()
        try await listingQuestionRepliesDocument(listingId: listingId, questionId: questionId, replyId: replyId).updateData([Question.CodingKeys.likeNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    func checkReplyLike(listingId: String, questionId: String, replyId: String, uid: String) async throws -> Bool {
        do{
            let doc = try  await listingQuestionReplyLikeDocument(listingId: listingId, questionId: questionId, replyId: replyId, uid: uid).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
    func removeReply(listingId: String, questionId: String, replyId: String) async throws{
        
        try await listingQuestionRepliesDocument(listingId: listingId, questionId: questionId, replyId: replyId).delete()
        try await listingQuestionDocument(listingId: listingId, questionId: questionId).updateData([Question.CodingKeys.replyNumber.rawValue : FieldValue.increment(-1.0)])

    }
    
    func removeQuestion(listingId: String, questionId: String) async throws{
        
        try await listingQuestionDocument(listingId: listingId, questionId: questionId).delete()
        try await listingDocument(listingId: listingId).updateData([Listing.CodingKeys.questionNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    
    func getQuestions(listingId: String , count: Int = 5, lastDocument: DocumentSnapshot?)  async throws -> (output: [Question] , lastDocument: DocumentSnapshot?){
        
        if let lastDocument = lastDocument {
            
            try await listingQuestionCollection(listingId: listingId)
                .order(by: Question.CodingKeys.time.rawValue, descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Question.self)
        } else {
            try await listingQuestionCollection(listingId: listingId)
                .order(by: Question.CodingKeys.time.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Question.self)
        }
   
    }
    
    func editQuestion(listingId: String, questionId: String, content: String) async throws{
        let data: [String: Any] = [
            Question.CodingKeys.content.rawValue : content,
            Question.CodingKeys.isEdited.rawValue : true
        ]
        try await listingQuestionDocument(listingId: listingId, questionId: questionId).updateData(data)

    }
    
    func editReply(listingId: String, questionId: String, replyId: String, content: String) async throws{
        
        let data: [String: Any] = [
            Question.CodingKeys.content.rawValue : content,
            Question.CodingKeys.isEdited.rawValue : true
        ]
        try await listingQuestionRepliesDocument(listingId: listingId, questionId: questionId, replyId: replyId).updateData(data)
    }
    
    
    func getQuestion(listingId: String, questionId: String) async throws -> Question {
        return try await listingQuestionDocument(listingId: listingId, questionId: questionId).getDocument(as: Question.self)
    }
    
    func getReply(listingId: String, questionId: String, replyId: String) async throws -> Question {
        return try await listingQuestionRepliesDocument(listingId: listingId, questionId: questionId, replyId: replyId).getDocument(as: Question.self)
    }
    
    
    func getInterestedIdByTime(listingId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            query = listingInterestedCollection(listingId: listingId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = listingInterestedCollection(listingId: listingId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let likersIds = snapshot.documents.compactMap { document in
            return document.get("id") as? String
        }
        
        return (likersIds, snapshot.documents.last)
    }
    
    func getQuestionLikersIdByTime(listingId: String, questionId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            
            query = listingQuestionLikesCollection(listingId: listingId, questionId: questionId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = listingQuestionLikesCollection(listingId: listingId, questionId: questionId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let likersIds = snapshot.documents.compactMap { document in
            return document.get("uid") as? String
        }
        
        return (likersIds, snapshot.documents.last)
    }
    
    
    func getReplyLikersIdByTime(listingId: String, questionId: String, replyId: String,  count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            
            query = listingQuestionReplyLikeCollection(listingId: listingId, questionId: questionId, replyId: replyId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = listingQuestionReplyLikeCollection(listingId: listingId, questionId: questionId, replyId: replyId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let likersIds = snapshot.documents.compactMap { document in
            return document.get("uid") as? String
        }
        
        return (likersIds, snapshot.documents.last)
    }
    
    func updateReportNumber(listingId: String) async throws {
        
        try await listingDocument(listingId: listingId).updateData([Listing.CodingKeys.reportNumber.rawValue : FieldValue.increment(1.0)])

    }
    
    func editListing(listing: Listing) async throws {
        try listingDocument(listingId: String(listing.id)).setData(from: listing, merge: true)
    }
   

}

    
    
    
    
    
    

