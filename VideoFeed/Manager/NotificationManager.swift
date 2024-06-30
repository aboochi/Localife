//
//  NotificationManager.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine



final class NotificationManager {
    
    static let shared = NotificationManager()
    private init() { }
    
    private let notificationCollection: CollectionReference = Firestore.firestore().collection("Notification")
    
    private var notificationListener: ListenerRegistration? = nil

    
    private func notificationsDocument(uid: String) -> DocumentReference {
        notificationCollection.document(uid)
    }
    
    private func userNotificationCollection(uid: String) -> CollectionReference {
        notificationsDocument(uid: uid).collection("Notification")
    }
    
    private func userNotificationDocument(uid: String, notificationId: String) -> DocumentReference {
        userNotificationCollection(uid: uid).document(notificationId)
    }
    
    func saveNotification(notification: NotificationObject) async throws {
        
        if let userId = notification.userIds.first, userId == notification.targetId{ return }
    
        do{
            let existingNotification = try await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).getDocument(as: NotificationObject.self)
            

            
            if let userId = notification.userIds.first, let index = existingNotification.userIds.firstIndex(of: userId){
                
                try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.userIds.rawValue: FieldValue.arrayRemove([existingNotification.userIds[index]])])
                try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.usernames.rawValue: FieldValue.arrayRemove([existingNotification.usernames[index]])])
                try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.userPhotoUrls.rawValue: FieldValue.arrayRemove([existingNotification.userPhotoUrls[index]])])
                try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.times.rawValue: FieldValue.arrayRemove([existingNotification.times[index]])])
                
               
            }
            
            
            try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.userIds.rawValue: FieldValue.arrayUnion(notification.userIds)])
            try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.usernames.rawValue: FieldValue.arrayUnion(notification.usernames)])
            try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.userPhotoUrls.rawValue: FieldValue.arrayUnion(notification.userPhotoUrls)])
            try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.times.rawValue: FieldValue.arrayUnion(notification.times)])
            
            try  await userNotificationDocument(uid: notification.targetId, notificationId: notification.id).updateData([NotificationObject.CodingKeys.time.rawValue: notification.time])
          
            
            
            
           
            
           
        } catch{
            try  userNotificationDocument(uid: notification.targetId, notificationId: notification.id).setData(from: notification)
        }
      
    }
    
    
    
    func removeNotification(userId: String,  targetId: String, notificationId: String ) async throws {
        
    
        do{
            let existingNotification = try await userNotificationDocument(uid: targetId, notificationId: notificationId).getDocument(as: NotificationObject.self)
           
            if let index = existingNotification.userIds.firstIndex(of: userId){
                
                if existingNotification.userIds.count == 1{
                    
                    try  await userNotificationDocument(uid: targetId, notificationId: notificationId).delete()
                    
                }else{
                    
                    try  await userNotificationDocument(uid: targetId, notificationId: notificationId).updateData([NotificationObject.CodingKeys.userIds.rawValue: FieldValue.arrayRemove([existingNotification.userIds[index]])])
                    try  await userNotificationDocument(uid: targetId, notificationId: notificationId).updateData([NotificationObject.CodingKeys.usernames.rawValue: FieldValue.arrayRemove([existingNotification.usernames[index]])])
                    try  await userNotificationDocument(uid: targetId, notificationId: notificationId).updateData([NotificationObject.CodingKeys.userPhotoUrls.rawValue: FieldValue.arrayRemove([existingNotification.userPhotoUrls[index]])])
                    try  await userNotificationDocument(uid: targetId, notificationId: notificationId).updateData([NotificationObject.CodingKeys.time.rawValue: FieldValue.arrayRemove([existingNotification.times[index]])])
                    
                    let time = existingNotification.times[existingNotification.times.count - 2]
                        try  await userNotificationDocument(uid: targetId, notificationId: notificationId).updateData([NotificationObject.CodingKeys.time.rawValue: time])
                    
                    
                   
                }
            }
        
        }
      
    }
    
    
    
    func fetchNotifications(currentUid: String, count: Int) -> AnyPublisher<[NotificationObject], Error> {
        let publisher = PassthroughSubject<[NotificationObject], Error>()
        
        
        self.notificationListener = userNotificationCollection(uid: currentUid)
            .order(by: Message.CodingKeys.time.rawValue, descending: true)
            .limit(to: count)

            .addSnapshotListener { querySnapshot, error in
                
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let notifications: [NotificationObject] = documents.compactMap({ try? $0.data(as: NotificationObject.self) })
            publisher.send(notifications)
        }
        
        return publisher.eraseToAnyPublisher()
    }
    
}
