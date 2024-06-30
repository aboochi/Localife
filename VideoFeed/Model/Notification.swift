//
//  Notification.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum NotificationCategoryEnum: String{
    case postLike = "postLike"
    case postComment = "postComment"
    case postReply = "postReply"
    case postMention = "postMention"
    case commentMention = "commentMension"
    case commentLike = "commentLike"
    case questionLike = "questionLike"
    case questionReplyLike = "questionReplyLike"
    case replyLike = "replyLike"
    case stroyLike = "storyLike"
    case listingQuestion = "listingQuestion"
    case listingInterested = "listingInterested"
    case questionReply = "questionReply"
    case questionMention = "questionMention"
    case message = "message"
    case follow = "follow"
    case acceptRequest = "acceptRequest"
}


struct NotificationObject: Codable, Identifiable, Hashable {
    
    let id: String
    let targetId: String
    let category: String
    var time: Timestamp
    var times: [Timestamp]
    var userIds: [String]
    var usernames: [String]
    var userPhotoUrls: [String]
    let postId: String?
    let postThumbnail: String?
    let storyId: String?
    let storyThumbnail: String?
    var text: String?
    var replyId: String?
    let mention: String?
    let commentId: String?
    let questionId: String?
    let listingId: String?
    let listingThumbnail: String?
    let messageId: String?
    let parentId: String?
    let parentUsername: String?
    
    init(id: String, targetId: String, category: String, userIds: [String] = [], usernames: [String] , userPhotoUrls: [String] , postId: String? = nil, postThumbnail: String? = nil, storyId: String? = nil, storyThumbnail: String? = nil, text: String? = nil, mention: String? = nil, commentId: String? = nil, replyId: String? = nil, questionId: String? = nil, listingId: String? = nil, listingThumbnail: String? = nil, messageId: String? = nil, parentId: String? = nil, parentUsername: String? = nil) {
        
        let currentTime = Timestamp()
        
        self.id = id
        self.targetId = targetId
        self.category = category
        self.time = currentTime
        self.times = [currentTime]
        self.userIds = userIds
        self.usernames = usernames
        self.userPhotoUrls = userPhotoUrls
        self.postId = postId
        self.postThumbnail = postThumbnail
        self.storyId = storyId
        self.storyThumbnail = storyThumbnail
        self.text = text
        self.mention = mention
        self.commentId = commentId
        self.replyId = replyId
        self.questionId = questionId
        self.listingId = listingId
        self.listingThumbnail = listingThumbnail
        self.messageId = messageId
        self.parentId = parentId
        self.parentUsername = parentUsername
    }
    
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case targetId = "targetId"
        case category = "category"
        case time = "time"
        case times = "times"
        case userIds = "userIds"
        case postId = "postId"
        case postThumbnail = "postThumbnail"
        case userPhotoUrls = "userPhotoUrls"
        case usernames = "usernames"
        case storyId = "storyId"
        case storyThumbnail = "storyThumbnail"
        case text = "text"
        case mention = "mention"
        case commentId = "commentId"
        case replyId = "replyId"
        case questionId = "questionId"
        case listingId = "listingId"
        case listingThumbnail = "listingThumbnail"
        case messageId = "messageId"
        case parentId = "parentId"
        case parentUsername = "parentUsername"
    }
   
}
