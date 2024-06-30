//
//  NotificationCellViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/30/24.
//

import Foundation

enum NotificationType {
    case aboutPost
    case aboutListing
    case aboutFollow
}


@MainActor
final class NotificationCellViewModel: ObservableObject{
    
    
    @Published var post : Post?
    @Published var listing : Listing?
    @Published var notificationOwner: DBUser?
    let notification: NotificationObject
    
    init(notification: NotificationObject, currentUser: DBUser){
        self.notification = notification
        
    }
    
    
    func fetchInfo() async throws{
        
        do{
            switch notificationType{
                
            case .aboutPost:
                
                
                if let notificationOwnerUid = notification.userIds.first{
                    notificationOwner = try await UserManager.shared.getUser(userId: notificationOwnerUid)
                }
                if let postId = notification.postId {
                    var fetchedPost = try await PostManager.shared.getPost(postId: postId)
                    fetchedPost.user = try await UserManager.shared.getUser(userId: fetchedPost.ownerUid)
                    post = fetchedPost
                }
                
            case .aboutListing:
                
                if let notificationOwnerUid = notification.userIds.first{
                    notificationOwner = try await UserManager.shared.getUser(userId: notificationOwnerUid)
                }
                if let listingId = notification.postId {
                    
                    var fetchedListing = try await ListingManager.shared.getListing(listingId: listingId)
                    fetchedListing.user = try await UserManager.shared.getUser(userId: fetchedListing.ownerUid)
                    listing = fetchedListing
                }
                
            case .aboutFollow:
                
                return 
                
                
                
            }
        }
       
    }
    
    
    var notificationType: NotificationType {
        
        if notification.category == NotificationCategoryEnum.postLike.rawValue || notification.category == NotificationCategoryEnum.postReply.rawValue || notification.category == NotificationCategoryEnum.postComment.rawValue || notification.category == NotificationCategoryEnum.commentMention.rawValue || notification.category == NotificationCategoryEnum.commentLike.rawValue || notification.category == NotificationCategoryEnum.replyLike.rawValue{
            
            return .aboutPost
            
        }else  if notification.category == NotificationCategoryEnum.listingQuestion.rawValue || notification.category == NotificationCategoryEnum.listingInterested.rawValue || notification.category == NotificationCategoryEnum.questionLike.rawValue || notification.category == NotificationCategoryEnum.questionReply.rawValue || notification.category == NotificationCategoryEnum.questionMention.rawValue || notification.category == NotificationCategoryEnum.questionReplyLike.rawValue{
        
            return .aboutListing
            
        }
        return .aboutFollow
    }
    
    
    
}
