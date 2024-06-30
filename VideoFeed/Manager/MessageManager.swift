//
//  MessageManager.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class MessageManager{
    
    static let shared = MessageManager()
    private init() { }
    
    private var messageListener: ListenerRegistration? = nil

    private let messagesCollection = Firestore.firestore().collection("Messages")
    
    private let lastMessagesCollection = Firestore.firestore().collection("LastMessages")
        
    private let unreadChatsCollection = Firestore.firestore().collection("UnreadChats")

    private func unreadChatsDocument(uid: String) -> DocumentReference {
        unreadChatsCollection.document(uid)
    }
    
    private func userUnreadChatCollection(currentUid: String) -> CollectionReference {
        unreadChatsDocument(uid: currentUid).collection("UnreadChats")
    }
    
    private func userUnreadChatDocument(currentUid: String, otherUid: String) -> DocumentReference {
        userUnreadChatCollection(currentUid: currentUid).document(otherUid)
    }

    
    private func messageDocument(uid: String) -> DocumentReference {
        messagesCollection.document(uid)
    }
    
    private func lastMessagesDocument(uid: String) -> DocumentReference {
        lastMessagesCollection.document(uid)
    }
    
    private func lastMessagesCollection(uid: String) -> CollectionReference {
        lastMessagesDocument(uid: uid).collection("lastMessages")
    }
    
    private func userMessageCollection(uid: String) -> CollectionReference {
        messageDocument(uid: uid).collection("userMessages")
    }
    
    private func userMessageDocument(currentUid: String, otherUid: String) -> DocumentReference {
        userMessageCollection(uid: currentUid).document(otherUid)
    }
    
    private func chatCollection(currentUid: String, otherUid: String) -> CollectionReference {
        userMessageDocument(currentUid: currentUid, otherUid: otherUid).collection("Chats")
    }
    
    private func chatDocument(currentUid: String, otherUid: String, messageId: String) -> DocumentReference {
        chatCollection(currentUid: currentUid, otherUid: otherUid).document(messageId)
    }
    
    
    func fetchMessages(currentUser: DBUser, otherUid: String, count: Int) -> AnyPublisher<[Message], Error> {
        
        let publisher = PassthroughSubject<[Message], Error>()
        
//        if currentUser.blockedIds.contains(otherUid){
//            publisher.send([])
//            return publisher.eraseToAnyPublisher()
//        }
        
        
        self.messageListener = chatCollection(currentUid: currentUser.id, otherUid: otherUid)
            .order(by: Message.CodingKeys.time.rawValue, descending: true)
            .limit(to: count)

            .addSnapshotListener { querySnapshot, error in
                
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let messages: [Message] = documents.compactMap({ try? $0.data(as: Message.self) })
            publisher.send(messages)
        }
        
        return publisher.eraseToAnyPublisher()
    }
    
    
    
    func fetchChats(currentUser: DBUser) -> AnyPublisher<[Message], Error> {
        let publisher = PassthroughSubject<[Message], Error>()
        
        var blockedIds = currentUser.blockedIds
        blockedIds.append(currentUser.id)
        
        self.messageListener = lastMessagesCollection(uid: currentUser.id)
            //.whereField(Message.CodingKeys.ownerId.rawValue, notIn: blockedIds)
            .order(by: Message.CodingKeys.time.rawValue, descending: true)
            .addSnapshotListener { querySnapshot, error in
                
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let messages: [Message] = documents.compactMap({ try? $0.data(as: Message.self) })
            publisher.send(messages)
        }
        
        return publisher.eraseToAnyPublisher()
    }
    
    func sendMessage(message: Message, otherUser: DBUser) async throws {
        try chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).setData(from: message, merge: false)
        try lastMessagesCollection(uid: message.ownerId).document(message.recipientId).setData(from: message, merge: false)
        
        if !otherUser.blockedIds.contains(message.ownerId){
            try lastMessagesCollection(uid: message.recipientId).document(message.ownerId).setData(from: message, merge: false)
            try chatDocument(currentUid: message.recipientId, otherUid: message.ownerId, messageId: message.id).setData(from: message, merge: false)
            let messageType: MessageTypeEnum = .text
            let unreadChat = UnreadChat(otherId: message.ownerId, time: message.time, lastMessageType: messageType.rawValue, text: message.text)
            try await setUnreadChat(currentId: message.recipientId, unreadChat: unreadChat)
        }

    }
    
    func markDeliver(message: Message) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.delivered.rawValue: true])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.delivered.rawValue: true])
    }
    
    func markSeen(message: Message) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.seen.rawValue: true])
        try await chatDocument(currentUid: message.recipientId, otherUid: message.ownerId, messageId: message.id).updateData([Message.CodingKeys.seen.rawValue: true])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.seen.rawValue: true])
        try await lastMessagesCollection(uid: message.recipientId).document(message.ownerId).updateData([Message.CodingKeys.seen.rawValue: true])
        
        try await decrementUnreadChat(currentId: message.recipientId, otherId: message.ownerId)
    }
    
    func markStarred(message: Message) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.starred.rawValue: true])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.starred.rawValue: true])
    }
    
    func markUnstarred(message: Message) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.starred.rawValue: false])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.starred.rawValue: false])
    }
    
    func hide(message: Message) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.isHidden.rawValue: true])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.isHidden.rawValue: true])
    }
    
    func unHide(message: Message) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.isHidden.rawValue: false])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.isHidden.rawValue: false])
    }
    
    func addEmoji(message: Message, uid: String, emoji: String) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).setData([Message.CodingKeys.reactions.rawValue: [uid: emoji]], merge: true)
        try await chatDocument(currentUid: message.recipientId, otherUid: message.ownerId, messageId: message.id).setData([Message.CodingKeys.reactions.rawValue: [uid: emoji]], merge: true)
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).setData([Message.CodingKeys.reactions.rawValue: [uid: emoji]], merge: true)
        try await lastMessagesCollection(uid: message.recipientId).document(message.ownerId).setData([Message.CodingKeys.reactions.rawValue: [uid: emoji]], merge: true)
    }
    
    
    func delete(message: Message) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.isDeleted.rawValue: true])
        try await chatDocument(currentUid: message.recipientId, otherUid: message.ownerId, messageId: message.id).updateData([Message.CodingKeys.isDeleted.rawValue: true])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.isDeleted.rawValue: true])
        try await lastMessagesCollection(uid: message.recipientId).document(message.ownerId).updateData([Message.CodingKeys.isDeleted.rawValue: true])
    }
    
    func edit(message: Message, newText: String) async throws {
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.isEdited.rawValue: true])
        try await chatDocument(currentUid: message.recipientId, otherUid: message.ownerId, messageId: message.id).updateData([Message.CodingKeys.isEdited.rawValue: true])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.isEdited.rawValue: true])
        try await lastMessagesCollection(uid: message.recipientId).document(message.ownerId).updateData([Message.CodingKeys.isEdited.rawValue: true])
        
        try await chatDocument(currentUid: message.ownerId, otherUid: message.recipientId, messageId: message.id).updateData([Message.CodingKeys.text.rawValue: newText])
        try await chatDocument(currentUid: message.recipientId, otherUid: message.ownerId, messageId: message.id).updateData([Message.CodingKeys.text.rawValue: newText])
        try await lastMessagesCollection(uid: message.ownerId).document(message.recipientId).updateData([Message.CodingKeys.text.rawValue: newText])
        try await lastMessagesCollection(uid: message.recipientId).document(message.ownerId).updateData([Message.CodingKeys.text.rawValue: newText])
    }
    
    func deleteChats(currentId: String, otherId: String) async throws {
       
        try await lastMessagesCollection(uid: currentId).document(otherId).delete()
    }
    
    
    func setUnreadChat(currentId: String, unreadChat: UnreadChat) async throws {
        
        do{
            let doc = try await userUnreadChatDocument(currentUid: currentId, otherUid: unreadChat.id).getDocument()
            if doc.exists{
                let data: [String: Any] = [
                    UnreadChat.CodingKeys.time.rawValue : unreadChat.time,
                    UnreadChat.CodingKeys.lastMessageType.rawValue : unreadChat.lastMessageType,
                    UnreadChat.CodingKeys.text.rawValue : unreadChat.text,
                ]
                try await userUnreadChatDocument(currentUid: currentId, otherUid: unreadChat.id).updateData(data)
                try await userUnreadChatDocument(currentUid: currentId, otherUid: unreadChat.id).updateData([UnreadChat.CodingKeys.messagesNumber.rawValue : FieldValue.increment(1.0)])
                
            }else{
                
                try userUnreadChatDocument(currentUid: currentId, otherUid: unreadChat.id).setData(from: unreadChat, merge: false)
            }
        } catch {
            throw error
        }
     
    }
    
    
    func decrementUnreadChat(currentId: String, otherId: String) async throws {
        
        do{
            let doc = try await userUnreadChatDocument(currentUid: currentId, otherUid: otherId).getDocument()
            if let numberOfUnreadMessages = doc.get(UnreadChat.CodingKeys.messagesNumber.rawValue) as? Int, numberOfUnreadMessages > 1{
                
                print("number of messages: >>>>>>>>>>  \(numberOfUnreadMessages)")
                try await userUnreadChatDocument(currentUid: currentId, otherUid: otherId).updateData([UnreadChat.CodingKeys.messagesNumber.rawValue : FieldValue.increment(-1.0)])
                
            }else{
                
                try await userUnreadChatDocument(currentUid: currentId, otherUid: otherId).delete()
            }
        } catch {
            throw error
        }
    }
    
    func getNumberOfUnreadChats(uid: String) async throws -> Int {
        let count = try await Int(truncating: userUnreadChatCollection(currentUid: uid).count.getAggregation(source: .server).count)
        return count
    }
    
    func fetchUnreadChats(currentUid: String) -> AnyPublisher<[String: UnreadChat], Error> {
        let publisher = PassthroughSubject<[String: UnreadChat], Error>()
        
        self.messageListener = userUnreadChatCollection(currentUid: currentUid)
            .order(by: UnreadChat.CodingKeys.time.rawValue, descending: true)
            .addSnapshotListener { querySnapshot, error in
                
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let chats: [UnreadChat] = documents.compactMap({ try? $0.data(as: UnreadChat.self) })
            
            let chatsDictionary: [String: UnreadChat] = Dictionary(uniqueKeysWithValues: chats.map { ($0.id, $0) })

            publisher.send(chatsDictionary)
        }
        
        return publisher.eraseToAnyPublisher()
    }
    
}







