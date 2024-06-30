//
//  Report.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/9/24.
//

enum ContentCategoryEnum: String{
    case post = "post"
    case listing = "listing"
    case story = "story"
    case user = "user"
    case message = "message"
}

enum ReportCategory: String, CaseIterable {
    case inappropriate = "Inappropriate Content"
    case harassment = "Harassment"
    case spam = "Spam or Scams"
    case misinformation = "Misinformation"
    case intellectualProperty = "Intellectual Property"
    case illegal = "Illegal Activities"
    case other = "Other"
}


import Foundation
import FirebaseFirestore

struct Report: Codable, Identifiable {
    
    let id: String
    let time: Timestamp
    let contentCategory: String
    let category: String
    let postId: String?
    let reportedUserId: String
    let reportingUserId: String
    let text: String?
    
    
    init(id: String, contentCategory: String, category: String, postId: String?, reportedUserId: String, reportingUserId: String, text: String?) {
        self.id = id
        self.time = Timestamp()
        self.contentCategory = contentCategory
        self.category = category
        self.postId = postId
        self.reportedUserId = reportedUserId
        self.reportingUserId = reportingUserId
        self.text = text
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case time = "time"
        case contentCategory = "contentCategory"
        case category = "category"
        case postId = "postId"
        case reportedUserId = "reportedUserId"
        case reportingUserId = "reportingUserId"
        case text = "text"
        
    }
  
}


