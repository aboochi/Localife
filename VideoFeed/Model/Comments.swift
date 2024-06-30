//
//  Comments.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/3/24.
//

import Foundation
import FirebaseFirestore

struct Comment: Codable, Identifiable, Hashable{
    let id: String
    let postId: String
    var commentOwnerId: String
    var commentOwnerUsername: String
    let postOwnerId: String
    let postOwnerusername: String
    let postThumbnail: String
    let likeNumber: Int
    let replyNumber: Int
    let time: Timestamp
    var content: String
    var parentCommentId: String?
    var mentionUsername: String?
    var mentionId: String?
    var isEdited: Bool
    
    var user: DBUser?    
    
    init(id: String,commentOwnerId: String, username: String, post: Post, content: String, comment: Comment? = nil){
        self.id = id
        self.postId = post.id
        self.commentOwnerId = commentOwnerId
        self.commentOwnerUsername = username
        self.postOwnerId = post.ownerUid
        self.likeNumber = 0
        self.replyNumber = 0
        self.time = Timestamp()
        self.content = content
        self.parentCommentId = comment?.id
        self.mentionId = comment?.commentOwnerId
        self.mentionUsername = comment?.commentOwnerUsername
        self.postOwnerusername = post.ownerUsername
        self.postThumbnail = post.thumbnailUrls.first ?? ""
        self.isEdited = false
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case postId = "postId"
        case commentOwnerId = "commentOwnerId"
        case commentOwnerUsername = "commentOwnerUsername"
        case postOwnerId = "postOwnerId"
        case likeNumber = "likeNumber"
        case replyNumber = "replyNumber"
        case time = "time"
        case content = "content"
        case parentCommentId = "parentCommentId"
        case mentionId = "mentionId"
        case mentionUsername = "mentionUsername"
        case postOwnerusername = "postOwnerusername"
        case postThumbnail = "postThumbnail"
        case isEdited = "isEdited"
 
    }
    
    mutating func setUserOwner() async throws{
        
        user = try await UserManager.shared.getUser(userId: commentOwnerId)
        
    }
    
    mutating func setOwnerId(siblingCommentId: String) {
        
        commentOwnerId = siblingCommentId
    }
    
    mutating func setOwnerUsername(siblingCommentUsername: String) {
        
        commentOwnerUsername = siblingCommentUsername
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


