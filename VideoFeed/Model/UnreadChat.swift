//
//  UnreadChat.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/29/24.
//


enum MessageTypeEnum: String{
    case text = "text"
    case image = "image"
    case video = "video"
    case listing = "listing"
    case post = "post"
    
}


import Foundation
import FirebaseFirestore

struct UnreadChat: Codable, Identifiable, Hashable {
    
    let id: String
    let time: Timestamp
    let messagesNumber: Int
    let lastMessageType: String
    let text: String
    
    
    
    init(otherId: String, time: Timestamp, lastMessageType: String, text: String = ""){
        self.id = otherId
        self.time = time
        self.messagesNumber = 1
        self.lastMessageType = lastMessageType
        self.text = text
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case time = "time"
        case messagesNumber = "messagesNumber"
        case lastMessageType = "lastMessageType"
        case text = "text"
    }
}
