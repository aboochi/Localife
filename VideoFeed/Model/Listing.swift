//
//  Listing.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/9/24.
//

import Foundation
import FirebaseFirestore

struct Listing: Codable, Identifiable, Hashable{
    var id: String
    let ownerUid: String
    var time: Timestamp
    let title: String
    let category: String
    var interestedNumber: Int
    var questionNumber: Int
    let validUntil: Timestamp
    let isPublic: Bool
    let neighborIDs: [String]?
    let allowMessage: Bool
    var isEdited: Bool
    let isUrgent: Bool
    let desiredTime: Timestamp?
    let endTime: Timestamp?
    let price: Double?
    var urls: [String]?
    var imageUrls: [String]?
    var thumbnailUrls: [String]?
    let description: String?
    var aspectRatio: CGFloat
    let originPlaceName: String?
    let originPlaceAddress: String?
    let destinationPlaceName: String?
    let destinationPlaceAdress: String?
    let originLocation: GeoPoint?
    let destinationLocation: GeoPoint?
    let originGeoHash5 : String?
    let originGeoHash6 : String?
    let originGeoHash7 : String?
    let destinationGeoHash5 : String?
    let destinationGeoHash6 : String?
    let destinationGeoHash7 : String?
    let ownerUsername: String
    let ownerPhotoUrl: String?
    var keywords: [String]
    var reportNumber: Int 




    
    var user: DBUser?
    
    
    init(id: String,
         ownerUid: String,
         title: String,
         category: String,
         validUntil: Timestamp? = nil,
         isPublic: Bool = true,
         neighborIDs: [String]? = nil,
         allowMessage: Bool = true,
         isEdited: Bool = false,
         isUrgent: Bool = false,
         desiredTime: Timestamp? = nil,
         endTime: Timestamp? = nil,
         price: Double? = 0,
         urls: [String]? = nil,
         imageUrls: [String]? = nil,
         thumbnailUrls: [String]? = nil,
         description: String? = nil,
         aspectRatio: CGFloat = 1,
         originPlaceName: String? = nil,
         originPlaceAddress: String? = nil,
         destinationPlaceName: String? = nil,
         destinationPlaceAdress: String? = nil,
         originLocation: GeoPoint? = nil,
         destinationLocation: GeoPoint? = nil,
         originGeoHash5 : String? = nil,
         originGeoHash6 : String? = nil,
         originGeoHash7 : String? = nil,
         destinationGeoHash5 : String? = nil,
         destinationGeoHash6 : String? = nil,
         destinationGeoHash7 : String? = nil,
         ownerUsername: String,
         ownerPhotoUrl: String?,
         keywords: [String]
         
         
         
    ) {
        
        
        var dateComponents = DateComponents()
        dateComponents.year = 1
        let oneYearFromNow = Calendar.current.date(byAdding: dateComponents, to: Date())!
        let oneYearTimestamp = Timestamp(date: oneYearFromNow)

        self.id = id
        self.ownerUid = ownerUid
        self.time = Timestamp()
        self.title = title
        self.category = category
        self.interestedNumber = 0
        self.questionNumber = 0
        self.validUntil = validUntil == nil ? oneYearTimestamp : validUntil!
        self.isPublic = isPublic
        self.neighborIDs = neighborIDs
        self.allowMessage = allowMessage
        self.isEdited = isEdited
        self.isUrgent = isUrgent
        self.desiredTime = desiredTime
        self.endTime = endTime
        self.price = price
        self.urls = urls
        self.imageUrls = imageUrls
        self.thumbnailUrls = thumbnailUrls
        self.description = description
        self.aspectRatio = aspectRatio
        self.originPlaceName = originPlaceName
        self.originPlaceAddress = originPlaceAddress
        self.destinationPlaceName = destinationPlaceName
        self.destinationPlaceAdress = destinationPlaceAdress
        self.user = nil
        self.originLocation = originLocation
        self.destinationLocation = destinationLocation
        self.originGeoHash5 = originGeoHash5
        self.originGeoHash6 = originGeoHash6
        self.originGeoHash7 = originGeoHash7
        self.destinationGeoHash5 = destinationGeoHash5
        self.destinationGeoHash6 = destinationGeoHash6
        self.destinationGeoHash7 = destinationGeoHash7
        self.ownerUsername = ownerUsername
        self.ownerPhotoUrl = ownerPhotoUrl
        self.keywords = keywords
        self.reportNumber = 0

    }
    
    

    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case ownerUid = "ownerUid"
        case time = "time"
        case title = "title"
        case category = "category"
        case interestedNumber = "interestedNumber"
        case questionNumber = "questionNumber"
        case validUntil = "validUntil"
        case isPublic = "isPublic"
        case neighborIDs = "neighborIDs"
        case allowMessage = "allowMessage"
        case isEdited = "isEdited"
        case isUrgent = "isUrgent"
        case desiredTime = "desiredTime"
        case endTime = "endTime"
        case price = "price"
        case urls = "urls"
        case imageUrls = "imageUrls"
        case thumbnailUrls = "thumbnailUrls"
        case description = "description"
        case aspectRatio = "aspectRatio"
        case originPlaceName = "originPlaceName"
        case originPlaceAddress = "originPlaceAddress"
        case destinationPlaceName = "destinationPlaceName"
        case destinationPlaceAdress = "destinationPlaceAdress"
        case user = "user"
        case originLocation = "originLocation"
        case destinationLocation = "destinationLocation"
        case originGeoHash5 = "originGeoHash5"
        case originGeoHash6 = "originGeoHash6"
        case originGeoHash7 = "originGeoHash7"
        case destinationGeoHash5 = "destinationGeoHash5"
        case destinationGeoHash6 = "destinationGeoHash6"
        case destinationGeoHash7 = "destinationGeoHash7"
        case ownerUsername = "ownerUsername"
        case ownerPhotoUrl = "ownerPhotoUrl"
        case keywords = "keywords"
        case reportNumber = "reportNumber"
    }
    
    
    mutating func setUserOwner() async throws{
        
        user = try await UserManager.shared.getUser(userId: ownerUid)
        
    }
    

    
}
