//
//  NotificationViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/30/24.
//


import SwiftUI
import FirebaseFirestore
import Combine


@MainActor
class NotificationViewModel: ObservableObject {
    
    @Published var notifications : [NotificationObject] = []
    private var cancellables = Set<AnyCancellable>()
    let currentUser: DBUser
    
    @Published var requestIds: [String] = []
    @Published var requestingUsers: [DBUser] = []

    var lastDocumentRequests: DocumentSnapshot?

    
    init(currentUser: DBUser){
        self.currentUser = currentUser
        
        fetchChats()
    
    }
    
    
    
    func fetchChats()  {
        
        NotificationManager.shared.fetchNotifications(currentUid: currentUser.id, count: 30)
         
            .sink { completion in
                
            } receiveValue: { [weak self ] notifications in
                //print("chats changed")
                self?.notifications = notifications
                
               
            }
            .store(in: &cancellables)

    }
    
    
    func getRequests() async throws {
        if requestIds.count > 0 && lastDocumentRequests == nil{ return }
        let results = try await UserManager.shared.getRequestIdByTime(userId: currentUser.id, count: 10, lastDocument: lastDocumentRequests)
        lastDocumentRequests = results.lastDocument
        requestIds.append(contentsOf: results.output)
        try await getUser(userIds: results.output)
        print("number of requests inside notification view model:    >>>>>>>>>>>> \(results.output)")
    }
    
    
    func getUser(userIds: [String]) async throws{
        
        
        for userId in userIds{
            
            do{
                let user = try await UserManager.shared.getUser(userId: userId)
                requestingUsers.append(user)
            }catch{
                continue
            }
        }
    }
    
    
    
    func acceptRequest(user: DBUser) async throws{
        
        try await UserManager.shared.addFollower(followerId: user.id, followedId: currentUser.id)
        try await UserManager.shared.removeRequest(followerId: user.id, followedId: currentUser.id)
        requestingUsers.removeAll(where: {$0.id == user.id})
        requestIds.removeAll(where: {$0 == user.id})
        
        
        let category = NotificationCategoryEnum.follow.rawValue
        let notitificationId = currentUser.id + user.id  + category
        let notification = NotificationObject(id: notitificationId, targetId: currentUser.id, category: category, userIds: [user.id], usernames: [user.username ?? "unknown"], userPhotoUrls: [user.photoUrl ?? "empty"])
        try await NotificationManager.shared.saveNotification( notification: notification)
        
        
        
        
        
    }
    
    func declineRequest(userId: String) async throws{
        
        try await UserManager.shared.removeRequest(followerId: userId, followedId: currentUser.id)
        requestingUsers.removeAll(where: {$0.id == userId})
        requestIds.removeAll(where: {$0 == userId})
    }

    
}

