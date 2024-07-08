//
//  UserInfo.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/17/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift




struct DBUser: Codable, Identifiable, Hashable {
    let id: String
    var username: String?
    let isAnonymous: Bool?
    let authProviders: [String]?
    var email: String?
    var photoUrl: String?
    let dateCreated: Date?
    let onBoaringState: Int?
    var firstName: String?
    var lastName: String?
    var followerNumber: Int
    var followingNumber: Int
    var requestNumber: Int
    var location: GeoPoint?
    var currentLocation: GeoPoint?
    var locationGeoHash: String?
    var currentLocationGeoHash: String?
    var locationGeoHash4: String?
    var locationGeoHash5: String?
    var locationGeoHash6: String?
    var privacyLevel: String
    var listingIds : [String]
    var listingsTimes : [Timestamp]
    var storyIds: [String]
    var storytimes: [Timestamp]
    var allowNotification: Bool
    var googleEmail: String?
    var appleEmail: String?
    var blockedIds: [String]
    var mutedIds: [String]
    var hiddenPostIds: [String]
    var bio: String?
    var reportNumber: Int = 0
    var listingCategory: [String]
    var firstSeenPostScore: Int
    var lastSeenPostScore: Int
    var followedByYou: Bool?
    var followingYou: Bool?
    var youRequested: Bool?

    

    init(auth: AuthDataUserModel, provider: [String], firstName: String? = "", lastName: String? = "", authProviderOption: AuthProviderOption = .anonymous) {
        
        let initialScore = Int(Date().timeIntervalSince1970) - (86400*5)
        let randomNumber = DBUser.generateRandom10DigitString()
        let guestUsername = "guest_" + randomNumber
        
        self.id = auth.uid
        self.username = guestUsername
        self.isAnonymous = auth.isAnonymous
        self.authProviders = provider
        self.email = authProviderOption == .email ? auth.email : nil
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.onBoaringState = auth.isAnonymous ? 3:0
        self.firstName = firstName
        self.lastName = lastName
        self.followerNumber = 0
        self.followingNumber = 0
        self.requestNumber = 0
        self.location = nil
        self.currentLocation = nil
        self.locationGeoHash = nil
        self.currentLocationGeoHash = nil
        self.locationGeoHash4 = nil
        self.locationGeoHash5 = nil
        self.locationGeoHash6 = nil
        self.privacyLevel = PrivacyLevel.publicAccess.rawValue
        self.listingIds = []
        self.listingsTimes = []
        self.storyIds = []
        self.storytimes = []
        self.allowNotification = true
        self.googleEmail = authProviderOption == .google ? auth.email : nil
        self.appleEmail = authProviderOption == .apple ? auth.email : nil
        self.blockedIds = []
        self.mutedIds = []
        self.reportNumber = 0
        self.hiddenPostIds =  []
        self.bio = nil
        self.listingCategory = []
        self.firstSeenPostScore = initialScore
        self.lastSeenPostScore = initialScore
        self.followedByYou = false
        self.followingYou = false
        self.youRequested = false

        

    }
    
    init(
        uid: String,
        username: String? = nil,
        isAnonymous: Bool? = nil,
        authProviders: [String]? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        onBoaringState: Int? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        followerNumber: Int = 0,
        followingNumber: Int = 0,
        requestNumber: Int = 0,
        privacyLevel: String = PrivacyLevel.publicAccess.rawValue,
        listingIds : [String] = [],
        storyIds :  [String] = [],
        listingsTimes : [Timestamp] = [],
        storytimes: [Timestamp] = [],
        googleEmail: String? = nil,
        appleEmail: String? = nil,
        blockedIds: [String] = [],
        mutedIds: [String] = []
        
        


    ) {
        let initialScore = Int(Date().timeIntervalSince1970) - (86400*5)

        self.id = uid
        self.username = username
        self.isAnonymous = isAnonymous
        self.authProviders = authProviders
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.onBoaringState = onBoaringState
        self.firstName = firstName
        self.lastName = lastName
        self.followerNumber = followerNumber
        self.followingNumber = followingNumber
        self.requestNumber =  requestNumber
        self.privacyLevel = privacyLevel
        self.listingIds = listingIds
        self.storyIds = storyIds
        self.listingIds = listingIds
        self.listingsTimes = listingsTimes
        self.storytimes = storytimes
        self.allowNotification = true
        self.googleEmail = googleEmail
        self.appleEmail = appleEmail
        self.blockedIds = blockedIds
        self.mutedIds = mutedIds
        self.hiddenPostIds =  []
        self.bio = nil
        self.listingCategory = []
        self.firstSeenPostScore = initialScore
        self.lastSeenPostScore = initialScore
        self.followedByYou = false
        self.followingYou = false
        self.youRequested = false
    
 
    }
     
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case isAnonymous = "isAnonymous"
        case authProviders = "authProviders"
        case email = "email"
        case photoUrl = "photoUrl"
        case dateCreated = "dateCreated"
        case onBoaringState = "onBoaringState"
        case firstName = "firstName"
        case lastName = "lastName"
        case followingNumber = "followingNumber"
        case followerNumber = "followerNumber"
        case location = "location"
        case currentLocation = "currentLocation"
        case locationGeoHash = "locationGeoHash"
        case currentLocationGeoHash = "currentLocationGeoHash"
        case locationGeoHash4 = "locationGeoHash4"
        case locationGeoHash5 = "locationGeoHash5"
        case locationGeoHash6 = "locationGeoHash6"
        case requestNumber = "requestNumber"
        case privacyLevel = "privacyLevel"
        case listingIds = "listingIds"
        case storyIds =  "storyIds"
        case listingsTimes = "listingsTimes"
        case storytimes = "storytimes"
        case allowNotification = "allowNotification"
        case googleEmail = "googleEmail"
        case appleEmail = "appleEmail"
        case blockedIds = "blockedIds"
        case mutedIds = "mutedIds"
        case reportNumber = "reportNumber"
        case hiddenPostIds = "hiddenPostIds"
        case bio = "bio"
        case listingCategory = "listingCategory"
        case firstSeenPostScore = "firstSeenPostScore"
        case lastSeenPostScore = "lastSeenPostScore"
        case followedByYou = "followedByYou"
        case followingYou = "followingYou"
        case youRequested = "youRequested"


    
    }
    
    static func generateRandom10DigitString() -> String {
        var randomString = ""
        for _ in 1...10 {
            let randomDigit = Int.random(in: 0...9)
            randomString.append(String(randomDigit))
        }
        return randomString
    }

}



