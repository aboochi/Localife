//
//  Story.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/7/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore



struct Story: Codable, Identifiable{
    
    let id: String
    let ownerUid: String
    let time: Timestamp
    var likeNumber: Int
    let imageUrl: String
    let thumbnailUrl: String
    let videoUrl: String?
    let aspectRatio: CGFloat
    
    
    
    var user: DBUser?
    
    init(id: String, ownerUid: String , imageUrl: String, thumbnailUrl: String, videoUrl: String?, aspectRaio: CGFloat){
           
           self.id = id
           self.ownerUid = ownerUid
           self.time = Timestamp()
           self.likeNumber = 0
           self.user = nil
           self.imageUrl = imageUrl
           self.thumbnailUrl = thumbnailUrl
           self.videoUrl = videoUrl
           self.aspectRatio = aspectRaio
          
 
       }
    

    enum CodingKeys: String, CodingKey {
            
            case id = "id"
            case ownerUid = "ownerUid"
            case time = "time"
            case likeNumber = "likeNumber"
            case user = "user"
            case imageUrl = "imageUrl"
            case thumbnailUrl = "thumbnailUrl"
            case videoUrl = "videoUrl"
            case aspectRatio = "aspectRatio"
            
        }
        
    mutating func setUserOwner() async throws{
        
        user = try await UserManager.shared.getUser(userId: ownerUid)
        
    }
    
    
    
    
    
    
}


