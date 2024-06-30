//
//  ListingCellviewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/5/24.
//

import Foundation


@MainActor
final class ListingCellviewModel: ObservableObject{
    
    let currentUser: DBUser
    @Published var listing: Listing
    @Published var wasInterested: Bool = false
    var listingUser : DBUser?
    
    init(currentUser: DBUser, listing: Listing ){
        self.currentUser = currentUser
        self.listing = listing
        self.listingUser = listing.user
        Task{
            try await checkInterest()
        }
       
    }
    
    
    
    func fetchListing() async throws{
        
        let user = listing.user
        var refreshedListing = try await ListingManager.shared.getListing(listingId: listing.id)
        refreshedListing.user = user
        listing = refreshedListing
    }
    
    
    
    func checkInterest() async throws {
        do{
            let result = try await ListingManager.shared.checkListingLike(listingId: listing.id, uid: currentUser.id)
            self.wasInterested = result
        } catch {
            throw error
        }
    }
    
    func like() async throws {
        
        
        listing.interestedNumber += 1
        self.wasInterested = true
        try await ListingManager.shared.addLike(listingId: listing.id, uid: currentUser.id)
        let notificationId = (listing.id)+(NotificationCategoryEnum.listingInterested.rawValue)
        let notification = NotificationObject(id: notificationId, targetId: listing.ownerUid, category: NotificationCategoryEnum.listingInterested.rawValue, userIds: [currentUser.id], usernames: [currentUser.username ?? "unknown"] , userPhotoUrls: [currentUser.photoUrl ?? "empty"], postId: listing.id , postThumbnail: listing.thumbnailUrls?.first,  parentId: listing.user?.id, parentUsername: listing.user?.username)
        try await NotificationManager.shared.saveNotification( notification: notification)
      
    }
    
    func unLike() async throws {
        listing.interestedNumber -= 1
        self.wasInterested = false
        try await ListingManager.shared.removeLike(listingId: listing.id, uid: currentUser.id)
        let notificationId = (listing.id)+(NotificationCategoryEnum.listingInterested.rawValue)
        try await NotificationManager.shared.removeNotification(userId: currentUser.id, targetId: listing.ownerUid, notificationId: notificationId)

    }
    
    
    
    
    
    
    func sendMesssage(text: String) async throws {
        var messageId : String = UUID().uuidString
     
        var newMessage = Message(id: messageId, ownerId: currentUser.id, recipientId: listing.ownerUid, text: text, ownerPhotoUrl: currentUser.photoUrl, ownerUsername: currentUser.username ?? "", recipientPhotoUrl: listing.ownerPhotoUrl, recipientUsername: listing.ownerUsername)
        
        newMessage.isAboutListing = true
        newMessage.ListingId = listing.id
        newMessage.sharedPostId = listing.id    
        newMessage.sharedPostThumbnail = listing.thumbnailUrls?.first
        if let url = listing.urls?.first, url.contains("Videos"){
            newMessage.sharedPostIsVideo = true
        }
        newMessage.sharedPostAspectRatio = listing.aspectRatio
       
        do{
            if listingUser == nil{
                listingUser = try await UserManager.shared.getUser(userId: listing.ownerUid)
                
            }
            if let otherUser = listingUser{
                try await MessageManager.shared.sendMessage(message: newMessage, otherUser: otherUser)
                try await MessageManager.shared.markDeliver(message: newMessage)
                print("message successfuly sent to firestore")
            }
            
        } catch{
            
        }
        
    }
    
    
    
    
    
    
    
    
}
