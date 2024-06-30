//
//  Question.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//



import Foundation
import FirebaseFirestore

struct Question: Codable, Identifiable{
    let id: String
    let listingId: String
    var questionOwnerId: String
    var questionOwnerUsername: String
    let listingOwnerId: String
    let listingOwnerusername: String
    let listingThumbnail: String
    let likeNumber: Int
    let replyNumber: Int
    let time: Timestamp
    var content: String
    var parentQuestionId: String?
    var mentionUsername: String?
    var mentionId: String?
    var isEdited: Bool
    
    var user: DBUser?
    
    init(id: String,questionOwnerId: String, username: String, listing: Listing, content: String, question: Question? = nil){
        self.id = id
        self.listingId = listing.id
        self.questionOwnerId = questionOwnerId
        self.questionOwnerUsername = username
        self.listingOwnerId = listing.ownerUid
        self.likeNumber = 0
        self.replyNumber = 0
        self.time = Timestamp()
        self.content = content
        self.parentQuestionId = question?.id
        self.mentionId = question?.questionOwnerId
        self.mentionUsername = question?.questionOwnerUsername
        self.listingOwnerusername = listing.ownerUsername
        self.listingThumbnail = listing.thumbnailUrls?.first ?? ""
        self.isEdited = false
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case listingId = "listingId"
        case questionOwnerId = "questionOwnerId"
        case questionOwnerUsername = "questionOwnerUsername"
        case listingOwnerId = "listingOwnerId"
        case likeNumber = "likeNumber"
        case replyNumber = "replyNumber"
        case time = "time"
        case content = "content"
        case parentQuestionId = "parentQuestionId"
        case mentionId = "mentionId"
        case mentionUsername = "mentionUsername"
        case listingOwnerusername = "listingOwnerusername"
        case listingThumbnail = "listingThumbnail"
        case isEdited = "isEdited"
 
    }
    
    mutating func setUserOwner() async throws{
        
        user = try await UserManager.shared.getUser(userId: questionOwnerId)
        
    }
    
    mutating func setOwnerId(siblingQuestionId: String) {
        
        questionOwnerId = siblingQuestionId
    }
    
    mutating func setOwnerUsername(siblingQuestionUsername: String) {
        
        questionOwnerUsername = siblingQuestionUsername
    }
    
    mutating func setUserOwner(user: DBUser?) {
        
        self.user = user
    }
    
    mutating func updateMentionUsername(mentionId: String) async throws {
        
        let updatedMention = try await UserManager.shared.getUser(userId: mentionId)
        if let username = updatedMention.username{
            mentionUsername  = username
            
        }
    }
    
    
    var timestampText: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time.dateValue(), to: Date()) ?? ""
    }
}



