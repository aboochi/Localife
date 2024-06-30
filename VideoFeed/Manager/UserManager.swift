//
//  UserManager.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import GeohashKit


final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private let reportCollection: CollectionReference = Firestore.firestore().collection("Report")
    
    func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func reportDocument(reportId: String) -> DocumentReference {
        reportCollection.document(reportId)
    }
    
    
    func savedPostsCollection(userId: String) -> CollectionReference{
        userDocument(userId: userId).collection("SavedPosts")
    }
    
    func savedPostsDocument(userId: String, postId: String) -> DocumentReference{
        savedPostsCollection(userId: userId).document(postId)
    }
    
    func savedListingsDocument(userId: String, listingId: String) -> DocumentReference{
        SavedListingsCollection(userId: userId).document(listingId)
    }

    
    func SavedListingsCollection(userId: String) -> CollectionReference{
        userDocument(userId: userId).collection("SavedListings")
    }
    
    func seenPostsCollection(userId: String) -> CollectionReference{
        userDocument(userId: userId).collection("SeenPosts")
    }
    
    func seenPostsDocument(userId: String, postId: String) -> DocumentReference{
        seenPostsCollection(userId: userId).document(postId)
    }
  
    func followersCollection(userId: String) -> CollectionReference{
        userDocument(userId: userId).collection("followers")
    }
    
    func followerDocument(userId: String, followerId: String) -> DocumentReference{
        followersCollection(userId: userId).document(followerId)
    }
    
    
    func followingCollection(userId: String) -> CollectionReference{
        userDocument(userId: userId).collection("following")
    }
    
    func followingDocument(userId: String, followedId: String) -> DocumentReference{
        followingCollection(userId: userId).document(followedId)
    }
    
    func requestsCollection(userId: String) -> CollectionReference{
        userDocument(userId: userId).collection("Requests")
    }
    
    func requestsDocument(userId: String, followerId: String) -> DocumentReference{
        requestsCollection(userId: userId).document(followerId)
    }
    

    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()

    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    func createNewUser(user: DBUser) async throws  {
        try userDocument(userId: user.id).setData(from: user, merge: false)
    }
    
  
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func updateUsername(userId: String, username: String) async throws {
        let data: [String:String] = [
            DBUser.CodingKeys.username.rawValue : username,
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
    
    
    func updateLocation(userId: String, location: CLLocationCoordinate2D) async throws {
    
        let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        var data: [String : Any] = [
            DBUser.CodingKeys.location.rawValue : geoPoint,
        ]
        
        if let geoHash = Geohash(coordinates: (location.latitude, location.longitude), precision: 12)?.geohash{
           data[DBUser.CodingKeys.locationGeoHash.rawValue] = geoHash
           data[DBUser.CodingKeys.locationGeoHash4.rawValue] = String(geoHash.prefix(4))
           data[DBUser.CodingKeys.locationGeoHash5.rawValue] = String(geoHash.prefix(5))
           data[DBUser.CodingKeys.locationGeoHash6.rawValue] = String(geoHash.prefix(6))
         
        }
        
      
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUserOnboardingState(userId: String, onBoardingState: Int) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.onBoaringState.rawValue : onBoardingState,
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUserPhotoURL(userId: String, url: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.photoUrl.rawValue : url,
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
   
    
    func getUsersByLocation(location: CLLocationCoordinate2D , count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [DBUser], lastDocument: DocumentSnapshot?) {
        let geohash = Geohash(coordinates: (location.latitude, location.longitude), precision: 5)
        var neighbors: [String] { 
            return getGeohashNeighborsLevel2(geohash: geohash)
        }
        //print("geohash neighbor list: \(neighbors)")

        if let lastDocument = lastDocument {
            return try await userCollection
                .order(by: DBUser.CodingKeys.dateCreated.rawValue, descending: false)
                .whereField(DBUser.CodingKeys.locationGeoHash5.rawValue, in: neighbors)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: DBUser.self)
        } else {
            return try await userCollection
                .order(by: DBUser.CodingKeys.dateCreated.rawValue, descending: false)
                .whereField(DBUser.CodingKeys.locationGeoHash5.rawValue, in: neighbors)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: DBUser.self)
        }
    }
    
    
    func getUsersByName(strSearch: String , count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [DBUser], lastDocument: DocumentSnapshot?) {
        
      let endSearch = getNextGreaterStr(strSearch: strSearch)
        
        print("str search: \(strSearch)")
        print("endSearch: \(endSearch)")


        if let lastDocument = lastDocument {
            return try await userCollection
            
                .whereField(DBUser.CodingKeys.username.rawValue, isGreaterThanOrEqualTo: strSearch)
                .whereField(DBUser.CodingKeys.username.rawValue, isLessThan: endSearch)
                //.order(by: DBUser.CodingKeys.dateCreated.rawValue, descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: DBUser.self)
        } else {
            return try await userCollection
                .whereField(DBUser.CodingKeys.username.rawValue, isGreaterThanOrEqualTo: strSearch)
                .whereField(DBUser.CodingKeys.username.rawValue, isLessThan: endSearch)
            

                //.order(by: DBUser.CodingKeys.dateCreated.rawValue, descending: false)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: DBUser.self)
        }
    }
    
    
    func getGeohashNeighborsLevel1(geohash: Geohash?) -> [String]{
        
            if let allNeighbors = geohash?.neighbors, let userGeohash = geohash?.geohash {
                var  neighborList = allNeighbors.all.map { $0.geohash }
                neighborList.append(userGeohash)
                
                return neighborList
            }else {return []}
    }
    
    func getGeohashNeighborsLevel2(geohash: Geohash?) -> [String] {
        guard let geohash = geohash, let allNeighbors = geohash.neighbors?.all else {
            return []
        }
        
        var neighborSet = Set<String>()
        
        // Add the initial geohash and its neighbors
        neighborSet.insert(geohash.geohash)
        for neighbor in allNeighbors {
            
                neighborSet.insert(neighbor.geohash)
            
        }
        
        // Iterate over the initial set of neighbors to add their neighbors
        for neighbor in allNeighbors {
            if let subNeighbors = neighbor.neighbors?.all {
                for subNeighbor in subNeighbors {
                    
                        neighborSet.insert(subNeighbor.geohash)
                    
                }
            }
        }
        
        return Array(neighborSet)
    }


    
    
    func getUsersByTime(count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [DBUser], lastDocument: DocumentSnapshot?) {
        
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -48, to: Date())!

        if let lastDocument = lastDocument {
            return try await userCollection
                .order(by: DBUser.CodingKeys.dateCreated.rawValue, descending: false)
               // .whereField(DBUser.CodingKeys.dateCreated.rawValue, isGreaterThan: twentyFourHoursAgo)
                .start(afterDocument: lastDocument)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: DBUser.self)
        } else {
            return try await userCollection
                .order(by: DBUser.CodingKeys.dateCreated.rawValue, descending: false)
                //.whereField(DBUser.CodingKeys.dateCreated.rawValue, isGreaterThan: twentyFourHoursAgo)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: DBUser.self)
        }
    }
    
    func checkUsernameAvailability(userId: String, username: String) async throws -> Bool {
        do{
            let doc = try  await userCollection
                       .whereField(DBUser.CodingKeys.username.rawValue, isEqualTo: username)
                       .getDocumentsWithSnapshot(as: DBUser.self)
           
            if let user = doc.output.first, user.id != userId{
                return false
            }else{
                return true
            }
            
        } catch {
            throw error
        }
    }
    
    
    func addSeenPost(userId: String, postId: String) async throws {
        try await seenPostsDocument(userId: userId, postId: postId).setData(["postId" : postId, "time" : Timestamp()])
    }
    
    
    func addFollower(followerId: String, followedId: String) async throws {
        try await followerDocument(userId: followedId, followerId: followerId).setData(["followerId" : followerId, "time" : Timestamp()])
        try await followingDocument(userId: followerId, followedId: followedId).setData(["followedId" : followedId, "time" : Timestamp()])
        try await userDocument(userId: followedId).updateData([DBUser.CodingKeys.followerNumber.rawValue : FieldValue.increment(1.0)])
        try await userDocument(userId: followerId).updateData([DBUser.CodingKeys.followingNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func removeFollower(followerId: String, followedId: String) async throws {
        try await followerDocument(userId: followedId, followerId: followerId).delete()
        try await followingDocument(userId: followerId, followedId: followedId).delete()
        try await userDocument(userId: followedId).updateData([DBUser.CodingKeys.followerNumber.rawValue : FieldValue.increment(-1.0)])
        try await userDocument(userId: followerId).updateData([DBUser.CodingKeys.followingNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    
    func addRequest(followerId: String, followedId: String) async throws {
        try await requestsDocument(userId: followedId, followerId: followerId).setData(["followerId" : followerId, "time" : Timestamp()])
        try await userDocument(userId: followedId).updateData([DBUser.CodingKeys.requestNumber.rawValue : FieldValue.increment(1.0)])
    }
    
    func removeRequest(followerId: String, followedId: String) async throws {
        try await requestsDocument(userId: followedId, followerId: followerId).delete()
        try await userDocument(userId: followedId).updateData([DBUser.CodingKeys.requestNumber.rawValue : FieldValue.increment(-1.0)])
    }
    
    
    
    func getFollowersIdByTime(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            query = followersCollection(userId: userId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = followersCollection(userId: userId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let followerIds = snapshot.documents.compactMap { document in
            return document.get("followerId") as? String
        }
        
        return (followerIds, snapshot.documents.last)
    }
    
    
    func getFollowingIdByTime(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            query = followingCollection(userId: userId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = followingCollection(userId: userId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let followingIds = snapshot.documents.compactMap { document in
            return document.get("followedId") as? String
        }
        
        return (followingIds, snapshot.documents.last)
    }
    
    func getRequestIdByTime(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (output: [String], lastDocument: DocumentSnapshot?) {
        let query: Query
        
        if let lastDocument = lastDocument {
            query = requestsCollection(userId: userId)
                .order(by: "time", descending: false)
                .start(afterDocument: lastDocument)
                .limit(to: count)
        } else {
            query = requestsCollection(userId: userId)
                .order(by: "time", descending: false)
                .limit(to: count)
        }
        
        let snapshot = try await query.getDocuments()
        
        let followerIds = snapshot.documents.compactMap { document in
            return document.get("followerId") as? String
        }
        
        return (followerIds, snapshot.documents.last)
    }
    
    func checkfollow(followerId: String, followedId: String) async throws -> Bool {
        do{
            let doc = try await followerDocument(userId: followedId, followerId: followerId).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
    func checkRequest(followerId: String, followedId: String) async throws -> Bool {
        do{
            let doc = try await requestsDocument(userId: followedId, followerId: followerId).getDocument()
            return doc.exists
        } catch {
            throw error
        }
    }
    
    

    
    func getNextGreaterStr(strSearch: String) -> String{
        
      
        let strLength = strSearch.count
        let strFrontCode = String(strSearch.prefix(strLength - 1))
        let strEndCode = String(strSearch.suffix(1))

        let startCode = strSearch
        return strFrontCode + String(UnicodeScalar(strEndCode.unicodeScalars.first!.value + 1)!)
    }
    
    
    func updateUserListing(uid: String, listingId: String, time: Timestamp) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.listingIds.rawValue: FieldValue.arrayUnion([listingId])])
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.listingsTimes.rawValue: FieldValue.arrayUnion([time])])

    }
    
    func removeUserListing(uid: String, listingId: String, time: Timestamp) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.listingIds.rawValue: FieldValue.arrayRemove([listingId])])
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.listingsTimes.rawValue: FieldValue.arrayRemove([time])])

    
    }
    
    func updatePrivacy(uid: String, privacy: PrivacyLevel) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.privacyLevel.rawValue: privacy.rawValue ])
  
    }
    
    func updateNotificationSetting(uid: String, enable: Bool) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.allowNotification.rawValue: enable ])
  
    }
    
    func blockUser(uid: String, targetUid: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.blockedIds.rawValue: FieldValue.arrayUnion([targetUid])])
  
    }
    
    func muteUser(uid: String, targetUid: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.mutedIds.rawValue: FieldValue.arrayUnion([targetUid])])

    }
    
    func hideContent(uid: String, contentId: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.hiddenPostIds.rawValue: FieldValue.arrayUnion([contentId])])
    }
    
    func unHideContent(uid: String, contentId: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.hiddenPostIds.rawValue: FieldValue.arrayRemove([contentId])])
    }
    
    func unBlockUser(uid: String, targetUid: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.blockedIds.rawValue: FieldValue.arrayRemove([targetUid])])
  
    }
    
    func unMuteUser(uid: String, targetUid: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.mutedIds.rawValue: FieldValue.arrayRemove([targetUid])])

    }
    
    func sendReport(report: Report) async throws  {
        try reportDocument(reportId: report.id).setData(from: report, merge: false)
        try await userDocument(userId: report.reportedUserId).updateData([DBUser.CodingKeys.reportNumber.rawValue: FieldValue.increment(1.0)])
        
    }
    
    func updateUsername(uid: String, username: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.username.rawValue: username])
    }
    
    func updateFirstName(uid: String, firstName: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.firstName.rawValue: firstName])
    }
    
    func updateLastName(uid: String, lastName: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.lastName.rawValue: lastName])
    }
    
    func updateBio(uid: String, bio: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.bio.rawValue: bio])
    }
    
    func updateLastSeenPostTime(uid: String, time: Timestamp) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.lastSeenPostTime.rawValue: time])
    }
    
    func deletePhotoUrl(uid: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.photoUrl.rawValue: FieldValue.delete()])
    }
    
    func addListingCategory(uid: String, category: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.listingCategory.rawValue: FieldValue.arrayUnion([category])])
    }

    func removeListingCategory(uid: String, category: String) async throws{
        try await userDocument(userId: uid).updateData([DBUser.CodingKeys.listingCategory.rawValue: FieldValue.arrayRemove([category])])
    }
    
    
    func getSavedPostIdsByTime(userId: String) async throws ->  [String] {
        let query: Query
                    query = savedPostsCollection(userId: userId)
                .order(by: "time", descending: false)
        
        let snapshot = try await query.getDocuments()
        let postIds = snapshot.documents.compactMap { document in
            return document.get("postId") as? String
        }
        
        return postIds
    }
    
    func getSavedListingIdsByTime(userId: String) async throws ->  [String] {
        let query: Query
                    query = SavedListingsCollection(userId: userId)
                .order(by: "time", descending: false)
        
        let snapshot = try await query.getDocuments()
        let listingIds = snapshot.documents.compactMap { document in
            return document.get("listingId") as? String
        }
        
        return listingIds
    }
    
    
    func getFollowerIds(userId: String) async throws ->  [String] {
        let query: Query
                    query = followersCollection(userId: userId)
               
        
        let snapshot = try await query.getDocuments()
        let followerIds = snapshot.documents.compactMap { document in
            return document.get("followerId") as? String
        }
        
        return followerIds
    }
    
    func getFollowingIds(userId: String) async throws ->  [String] {
        let query: Query
                    query = followingCollection(userId: userId)
             
        
        let snapshot = try await query.getDocuments()
        let followingIds = snapshot.documents.compactMap { document in
            return document.get("followedId") as? String
        }
        
        return followingIds
    }
    
    func getRequestIds(userId: String) async throws ->  [String] {
        let query: Query
                    query = requestsCollection(userId: userId)
             
        
        let snapshot = try await query.getDocuments()
        let requestIds = snapshot.documents.compactMap { document in
            return document.get("followerId") as? String
        }
        
        return requestIds
    }
    
    
    func getSeenPostIds(userId: String) async throws ->  [String] {
        let query: Query
                    query = seenPostsCollection(userId: userId)
               
        
        let snapshot = try await query.getDocuments()
        let postIds = snapshot.documents.compactMap { document in
            return document.get("postId") as? String
        }
        
        return postIds
    }
    
    
    func savePost(postId: String, userId: String) async throws {
        try await savedPostsDocument(userId: userId, postId: postId).setData(["postId" : postId, "time" : Timestamp()])
    }
    
    func unSavePost(postId: String, userId: String) async throws {
        try await savedPostsDocument(userId: userId, postId: postId).delete()
    }
    
    func saveListing(listingId: String, userId: String) async throws {
        try await savedListingsDocument(userId: userId, listingId: listingId).setData(["listingId" : listingId, "time" : Timestamp()])
    }
    
    func unSaveListing(listingId: String, userId: String) async throws {
        try await savedListingsDocument(userId: userId, listingId: listingId).delete()
    }
    
    
    
}

