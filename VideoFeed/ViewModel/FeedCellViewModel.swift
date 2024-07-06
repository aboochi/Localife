//
//  FeedCellViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/3/24.
//

import Foundation
import FirebaseFirestore


@MainActor
final class FeedCellViewModel: ObservableObject{
    @Published var post: Post
    let currentUser: DBUser
    @Published var didLike: Bool = false
    @Published var likerIds: [String] = []
    

    var lastDocumentLikers: DocumentSnapshot?

    
    init(post: Post, currentUser: DBUser){
        self.post = post
        self.currentUser = currentUser
        Task{
            try await checkLike()
        }
     
    }
    
    func checkLike() async throws {
        do{
            let result = try await PostManager.shared.checkPostLike(postId: post.id, uid: currentUser.id)
            self.didLike = result
        } catch {
            throw error
        }
    }
    
    func like() async throws {
        post.likeNumber += 1
        self.didLike = true
        try await PostManager.shared.addLike(postId: post.id, uid: currentUser.id)
        let notificationId = (post.id)+(NotificationCategoryEnum.postLike.rawValue)
        let notification = NotificationObject(id: notificationId, targetId: post.ownerUid, category: NotificationCategoryEnum.postLike.rawValue, userIds: [currentUser.id], usernames: [currentUser.username ?? "unknown"] , userPhotoUrls: [currentUser.photoUrl ?? "empty"], postId: post.id , postThumbnail: post.thumbnailUrls.first,  parentId: post.user?.id, parentUsername: post.user?.username)
        try await NotificationManager.shared.saveNotification( notification: notification)
        
    }
    
    
    func unLike() async throws {
        post.likeNumber -= 1
        self.didLike = false
        try await PostManager.shared.removeLike(postId: post.id, uid: currentUser.id)
        
        let notificationId = (post.id)+(NotificationCategoryEnum.postLike.rawValue)
        try await NotificationManager.shared.removeNotification(userId: currentUser.id, targetId: post.ownerUid, notificationId: notificationId)
        
    }
    
    var likeLabel: String {
        
            let label = post.likeNumber == 1 ? "like" : "likes"
            return "\(post.likeNumber) \(label)"
    }
    
    
    func getTime() -> String{
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: post.time.dateValue(), to: Date()) ?? ""
    }
    
    func getLikers() async throws {
        if likerIds.count > 0 && lastDocumentLikers == nil{ return }
        let results = try await PostManager.shared.getLikersIdByTime(postId: post.id, count: 10, lastDocument: lastDocumentLikers)
        lastDocumentLikers = results.lastDocument
        likerIds.append(contentsOf: results.output)
    }
    
    
    func savePost() async throws{
        
        try await UserManager.shared.savePost(postId: post.id, userId: currentUser.id)
    }
    
    
    
    func unSavePost() async throws{
        
        try await UserManager.shared.unSavePost(postId: post.id, userId: currentUser.id)
    }
    
    
    func addPostSeen(postTime: Timestamp) async throws{
        
        //try await UserManager.shared.addSeenPost(userId: currentUser.id, postId: post.id)
        
        //try await PostManager.shared.addSeen(postId: post.id, uid: currentUser.id)
        
       
    }
    
}
