//
//  Message.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Message: Codable, Identifiable, Hashable {
    
    
    
    var id: String
    var ownerId: String
    var recipientId: String
    var time: Timestamp
    var delivered: Bool
    var seen: Bool
    let timeSeen: Timestamp?
    var text: String
    let caption: String?
    var urls: [String]?
    var imageUrls: [String]?
    var thumbnailUrls: [String]?
    var isReply: Bool
    var replyMessageOwnerId: String?
    var replyToMessageId: String?
    var repliedText: String?
    var repliedImageUrl: String?
    var reactions: [String: String]?
    let isLink: Bool
    var starred: Bool
    var isPost: Bool
    var isStory: Bool
    var isEdited: Bool
    var isDeleted: Bool
    var isHidden: Bool
    var isForwarded: Bool
    var isReported: Bool
    let isNeighbor: Bool
    var isAboutListing: Bool
    var ListingId: String?
    var aspectRatio: CGFloat?
    var isSender: Bool?
    var ownerPhotoUrl: String?
    var ownerUsername: String
    var recipientPhotoUrl: String?
    var recipientUsername: String
    var sharedPostId: String?
    
    var isListing: Bool
    var isReplyToPost: Bool
    var isReplyToListing: Bool
    var sharedPostThumbnail: String?
    var sharedPostIsVideo: Bool?
    var sharedPostAspectRatio: CGFloat?
    var sharedPostOwnerUsername: String?
    var sharedPostOwnerPhotoUrl: String?
    var sharedPostCaption: String?
    
    var user: DBUser?
    var croppedImage: [UIImage]?
    
    var timestampText: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time.dateValue(), to: Date()) ?? ""
    }
    
    var timestampTextReal: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time.dateValue())
    }
    
    
    var timestampDate: String? {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let now = Date()
        
        if calendar.isDateInToday(time.dateValue()) {
            return "Today"
        } else if calendar.isDate(time.dateValue(), equalTo: now, toGranularity: .year) {
            dateFormatter.dateFormat = "MMM d, EEEE"
            return dateFormatter.string(from: time.dateValue())
        } else {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: time.dateValue())
        }
    }


    
    init(
        id: String,
        ownerId: String,
        recipientId: String,
        text: String,
        caption: String? = nil,
        urls: [String]? = nil,
        imageUrls: [String]? = nil,
        thumbnailUrls: [String]? = nil,
        isReply: Bool = false,
        replyToMessageId: String? = nil,
        repliedText: String? = nil,
        repliedImageUrl: String? = nil,
        replyMessageOwnerId: String? = nil,
        starred: Bool = false,
        isPost: Bool = false,
        isStory: Bool = false,
        isForwarded: Bool = false,
        isNeighbor: Bool = false,
        isAboutListing: Bool = false,
        listingId: String? = nil,
        aspectRatio: CGFloat? = nil,
        ownerPhotoUrl: String?,
        ownerUsername: String,
        recipientPhotoUrl: String?,
        recipientUsername: String,
        sharedPostId: String? = nil,
        isListing: Bool = false,
        isReplyToPost: Bool = false,
        sharedPostThumbnail: String? = nil,
        sharedPostIsVideo: Bool? = nil,
        sharedPostAspectRatio: CGFloat? = nil,
        sharedPostOwnerUsername: String? = nil,
        sharedPostOwnerPhotoUrl: String? = nil,
        sharedPostCaption: String? = nil,
        isReplyToListing: Bool = false

        
    ){
        self.id = id
        self.ownerId = ownerId
        self.recipientId = recipientId
        self.time  = Timestamp()
        self.delivered = false
        self.seen = false
        self.timeSeen = nil
        self.text = text
        self.caption = caption
        self.urls = urls
        self.imageUrls = imageUrls
        self.thumbnailUrls = thumbnailUrls
        self.isReply = isReply
        self.replyToMessageId = replyToMessageId
        self.repliedText = repliedText
        self.repliedImageUrl = repliedImageUrl
        self.replyMessageOwnerId = replyMessageOwnerId
        self.reactions = nil
        self.isLink = false
        self.starred = false
        self.isPost = isPost
        self.isStory = isStory
        self.isEdited = false
        self.isDeleted = false
        self.isHidden = false
        self.isForwarded = isForwarded
        self.isReported = false
        self.isNeighbor = isNeighbor
        self.isAboutListing = isAboutListing
        self.ListingId = listingId
        self.aspectRatio = aspectRatio
        self.isSender = nil
        self.user = nil
        self.ownerPhotoUrl = ownerPhotoUrl
        self.ownerUsername = ownerUsername
        self.recipientPhotoUrl = recipientPhotoUrl
        self.recipientUsername = recipientUsername
        self.sharedPostId =  sharedPostId
        self.isReplyToPost = isReplyToPost
        self.isListing = isListing
        self.sharedPostThumbnail = sharedPostThumbnail
        self.sharedPostIsVideo = sharedPostIsVideo
        self.sharedPostAspectRatio = sharedPostAspectRatio
        self.sharedPostOwnerUsername = sharedPostOwnerUsername
        self.sharedPostOwnerPhotoUrl =  sharedPostOwnerPhotoUrl
        self.sharedPostCaption = sharedPostCaption
        self.isReplyToListing = isReplyToListing

        
    }
    
    
    enum CodingKeys: String, CodingKey {
            
        case id = "id"
        case ownerId = "ownerId"
        case recipientId = "recipientId"
        case time = "time"
        case delivered = "delivered"
        case seen = "seen"
        case timeSeen = "timeSeen"
        case text = "text"
        case caption = "caption"
        case urls = "urls"
        case imageUrls = "imageUrls"
        case thumbnailUrls = "thumbnailUrls"
        case isReply = "isReply"
        case replyToMessageId = "replyToMessageId"
        case repliedText = "repliedText"
        case repliedImageUrl = "repliedImageUrl"
        case replyMessageOwnerId = "replyMessageOwnerId"
        case reactions = "reactions"
        case isLink = "isLink"
        case starred = "starred"
        case isPost = "isPost"
        case isStory = "isStory"
        case isEdited = "isEdited"
        case isDeleted = "isDeleted"
        case isHidden = "isHidden"
        case isForwarded = "isForwarded"
        case isReported = "isReported"
        case isNeighbor = "isNeighbor"
        case isAboutListing =  "isAboutListing"
        case ListingId = "ListingId"
        case aspectRatio = "aspectRatio"
        case isSender =  "isSender"
        case ownerPhotoUrl = "ownerPhotoUrl"
        case ownerUsername = "ownerUsername"
        case recipientPhotoUrl = "recipientPhotoUrl"
        case recipientUsername = "recipientUsername"
        case sharedPostId =  "sharedPostId"
        case isReplyToPost = "isReplyToPost"
        case isListing = "isListing"
        case sharedPostThumbnail = "sharedPostThumbnail"
        case sharedPostIsVideo = "sharedPostIsVideo"
        case sharedPostAspectRatio = "sharedPostAspectRatio"
        case sharedPostOwnerUsername = "sharedPostOwnerUsername"
        case sharedPostOwnerPhotoUrl =  "sharedPostOwnerPhotoUrl"
        case sharedPostCaption = "sharedPostCaption"
        case isReplyToListing = "isReplyToListing"
        
        
        case user = "user"
        
            
        }
    

    mutating func setUserOwner(uid: String) async throws{
        
        user = try await UserManager.shared.getUser(userId: uid)
        
    }
}












