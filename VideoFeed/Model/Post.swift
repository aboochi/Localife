//
//  Post.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/29/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

enum PostCategory: String{
    case general = "general"
    case lifestyle = "lifestyle"
}



struct Post: Codable, Identifiable , Hashable {
    
    var id: String
    let ownerUid: String
    let time: Timestamp
    let caption: String
    var likeNumber: Int
    let commentNumber: Int
    let category: String
    var urls: [String]
    var imageUrls: [String]
    var thumbnailUrls: [String]
    var aspectRatio: CGFloat
    var ownerUsername: String
    var ownerPhotoUrl: String
    var reportNumber: Int = 0
    var seenUserIds: [String]

   
    var user: DBUser?
    
    init(id: String, ownerUid: String, caption: String = "", category: String = "general", urls: [String], imageUrls: [String], thumbnailUrls: [String], aspectRaio: CGFloat, ownerUsername: String, ownerPhotoUrl: String){
           
           self.id = id
           self.ownerUid = ownerUid
           self.time = Timestamp()
           self.caption = caption
           self.likeNumber = 0
           self.commentNumber = 0
           self.category = category
           self.user = nil
           self.urls = urls
           self.imageUrls = imageUrls
           self.thumbnailUrls = thumbnailUrls
           self.aspectRatio = aspectRaio
           self.ownerUsername = ownerUsername
           self.ownerPhotoUrl = ownerPhotoUrl
           self.reportNumber = 0
           self.seenUserIds = []

       
        
       }
    

    
    enum CodingKeys: String, CodingKey {
            
            case id = "id"
            case ownerUid = "ownerUid"
            case time = "time"
            case caption = "caption"
            case likeNumber = "likeNumber"
            case commentNumber = "commentNumber"
            case category = "category"
            case user = "user"
            case urls = "urls"
            case aspectRatio = "aspectRatio"
            case imageUrls = "imageUrls"
            case thumbnailUrls = "thumbnailUrls"
            case ownerUsername = "ownerUsername"
            case ownerPhotoUrl = "ownerPhotoUrl"
            case reportNumber = "reportNumber"
            case seenUserIds = "seenUserIds"
             

            
        }
        
    mutating func setUserOwner() async throws{
        
        user = try await UserManager.shared.getUser(userId: ownerUid)
        
    }
    
    
    
    
    
    
}


