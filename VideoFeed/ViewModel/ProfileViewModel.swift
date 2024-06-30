//
//  ProfileViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/23/24.
//

import Foundation
import FirebaseFirestore
import CoreLocation


@MainActor
final class ProfileViewModel: ObservableObject{
    
    @Published var isFollowing: Bool = false
    @Published var requested: Bool = false
    var isMyOwnAccount: Bool {user.id == currentUser.id}
    @Published var followingStatement : String = "Follow"
    @Published var FollowingYou : Bool = false
    @Published var blockedUsers: [DBUser] = []
    
    var lastDocumentFollowers: DocumentSnapshot?
    var lastDocumentFollowing: DocumentSnapshot?
    var lastDocumentRequests: DocumentSnapshot?
    var lastDocumentNeighbors: DocumentSnapshot?
    var lastPostDocument: DocumentSnapshot?
    var lastListingDocument: DocumentSnapshot?
    var lastDocumentUserNeighbor: DocumentSnapshot?

    
    @Published var postsContainsPopular: Bool = false
    
    
    @Published var followerIds: [String] = []
    @Published var followingIds: [String] = []
    @Published var requestIds: [String] = []
    @Published var neighborIds: [String] = []
    
    @Published var followers: [DBUser] = []
    
    @Published var posts: [Post] = []
    @Published var allPosts: [Post] = []
    @Published var popularPostIndex: Int = 0
    
    @Published var listings: [Listing] = []
    @Published var mostPopularpost: Post?
    @Published var mostRecentListing: Listing?
    
    
    @Published  var user: DBUser
    @Published  var currentUser: DBUser
    @Published var isBlocked: Bool = false
    @Published var isMuted: Bool = false
    @Published var youAreBlocked: Bool = false
    
    @Published var savedPostIds: [String] = []
    @Published var savedPostIndex: Int = 0
    @Published var savedPosts: [Post] = []
    @Published var usersNeighbor: [DBUser] = []


    
    init(user: DBUser, currentUser: DBUser){
        self.user = user
        self.currentUser = currentUser
        Task{
            if user.username == "placeholder"{
                self.user = try await UserManager.shared.getUser(userId: user.id)
            }
            try await setFollowingStatus()
            try await setRequestStatus()
            checkBlockAndMute()
            
        }
    }
    
    
    
    func refreshUser() async throws{
        self.user =  try await UserManager.shared.getUser(userId: user.id)
    }
    
    func follow(currentUser: DBUser, user: DBUser) async throws{
        
        
        
        try await UserManager.shared.addFollower(followerId: currentUser.id, followedId: user.id)
        
        let category = NotificationCategoryEnum.follow.rawValue
        let notitificationId = user.id + currentUser.id + category
        let notification = NotificationObject(id: notitificationId, targetId: user.id, category: category, userIds: [currentUser.id], usernames: [currentUser.username ?? "unknown"], userPhotoUrls: [currentUser.photoUrl ?? "empty"])
        try await NotificationManager.shared.saveNotification( notification: notification)
        
        
    }
    

    
    func follow() async throws{
        isFollowing = true
        user.followerNumber += 1
        followerIds.append(currentUser.id)
        try await UserManager.shared.addFollower(followerId: currentUser.id, followedId: user.id)
        
        let category = NotificationCategoryEnum.follow.rawValue
        let notitificationId = user.id + currentUser.id + category
        let notification = NotificationObject(id: notitificationId, targetId: user.id, category: category, userIds: [currentUser.id], usernames: [currentUser.username ?? "unknown"], userPhotoUrls: [currentUser.photoUrl ?? "empty"])
        try await NotificationManager.shared.saveNotification( notification: notification)
        
        
    }
    
    func request() async throws{
        requested = true
        try await UserManager.shared.addRequest(followerId: currentUser.id, followedId: user.id)
        
    }
    
    
    func request(currentUser: DBUser, user: DBUser) async throws{
       
        try await UserManager.shared.addRequest(followerId: currentUser.id, followedId: user.id)
        
    }
    
    func unfollow(currentUser: DBUser, user: DBUser) async throws{
       
        try await UserManager.shared.removeFollower(followerId: currentUser.id, followedId: user.id)
        
    }
    
    
    
    func unfollow() async throws{
        isFollowing = false
        user.followerNumber -= 1
        followerIds.removeAll{$0 == currentUser.id}
        try await UserManager.shared.removeFollower(followerId: currentUser.id, followedId: user.id)
        
    }
    
    func removefollower(userId: String) async throws {
        try await UserManager.shared.removeFollower(followerId: userId, followedId: currentUser.id)
    }
    
    func acceptRequest(userId: String) async throws {
        try await UserManager.shared.addFollower(followerId: userId, followedId: currentUser.id)
    }
    
    func setFollowingStatus() async throws {
        isFollowing = try await UserManager.shared.checkfollow(followerId: currentUser.id, followedId: user.id)
        FollowingYou = try await UserManager.shared.checkfollow(followerId: user.id, followedId: currentUser.id)
    }
    
    func setRequestStatus() async throws {
        requested = try await UserManager.shared.checkRequest(followerId: currentUser.id, followedId: user.id)
    }
    
    func getFollowers() async throws {
        if followerIds.count > 0 && lastDocumentFollowers == nil{ return }
        let results = try await UserManager.shared.getFollowersIdByTime(userId: user.id, count: 10, lastDocument: lastDocumentFollowers)
        lastDocumentFollowers = results.lastDocument
        followerIds.append(contentsOf: results.output)
        
        //try await fetchusers(FetchedIds: results.output)
    }
    
    func getFollowing() async throws {
        if followingIds.count > 0 && lastDocumentFollowing == nil{ return }
        let results = try await UserManager.shared.getFollowingIdByTime(userId: user.id, count: 10, lastDocument: lastDocumentFollowing)
        lastDocumentFollowing = results.lastDocument
        followingIds.append(contentsOf: results.output)
    }
    
    func getRequests() async throws {
        if requestIds.count > 0 && lastDocumentRequests == nil{ return }
        let results = try await UserManager.shared.getRequestIdByTime(userId: user.id, count: 10, lastDocument: lastDocumentRequests)
        lastDocumentRequests = results.lastDocument
        requestIds.append(contentsOf: results.output)
    }
    
    
    func fetchusers(FetchedIds: [String]) async throws{
        for id in FetchedIds{
            do{
                let user = try await UserManager.shared.getUser(userId: id)
                followers.append(user)
                
            } catch{
                continue
            }
        }
    }
    
    
    
    func fetchPost() async throws{
        
        print("fetched post called >>>>>>>>")
        if posts.count > 0 && lastPostDocument == nil{ return}
        
        do{
            var fetchResult = try await PostManager.shared.getPostsByTimeAndId(userId: user.id, count: 10, lastDocument: lastPostDocument)
            lastPostDocument = fetchResult.lastDocument
            //posts.append(contentsOf: fetchResult.output)
            //allPosts = posts
            addUser(fetchedPosts: fetchResult.output)
        }
        
    }
    
    
    
    func fetchUserActiveListing() async throws{
        if listings.count > 0 && lastListingDocument == nil{ return}
        let fetchResult = try await ListingManager.shared.getListingsActiveByTimeAndUid(count: 10, uid: user.id, lastDocument: lastListingDocument)
        lastListingDocument = fetchResult.lastDocument
        addUser(fetchedListings: fetchResult.output)

    }
    
    
    func fetchPopularPost() async throws{
        
        
        let fetchResult = try await PostManager.shared.getPostsByLikeAndId(userId: user.id, count: 1, lastDocument: nil)
        
        
        if let popularPost = fetchResult.output.first{
            mostPopularpost = popularPost
            
            
        }
        
        
    }
    
    
    func addUser(fetchedListings: [Listing]) {
 
            for var listing  in fetchedListings{
                
                listing.user = user
                self.listings.append(listing)
                
            }
    }
    
 
    func addUser(fetchedPosts: [Post]) {
        
        if let mostPopularpost = mostPopularpost{
            
            for (index, var post)  in fetchedPosts.enumerated(){
                if post.id == mostPopularpost.id {
                    postsContainsPopular = true
                    popularPostIndex = allPosts.count 
                }
                post.user = user
                self.posts.append(post)
                self.allPosts.append(post)
            }
            
            
            
            if !postsContainsPopular && fetchedPosts.count == self.posts.count{
                var newPost = mostPopularpost
                let newId = UUID().uuidString
                newPost.id = newId
                self.mostPopularpost = newPost
                newPost.user = user
                allPosts.insert(newPost, at: 0)
                
            }
            
            
        }
    }
    
    func updatePrivacy(privacy: PrivacyLevel) async throws{
        
        try await UserManager.shared.updatePrivacy(uid: currentUser.id, privacy: privacy)
    }
    
    func updateNotificationSetting(enable: Bool) async throws{
        
        try await UserManager.shared.updateNotificationSetting(uid: currentUser.id, enable: enable)
    }
    
    func blockUser() async throws{
        isBlocked = true
        try await UserManager.shared.blockUser(uid: currentUser.id, targetUid: user.id)
        currentUser.blockedIds.append(user.id)
        if isFollowing{
            try await unfollow()
        }
        if FollowingYou{
            try await removefollower(userId: user.id)
        }
        
        
    }
    
    func unBlockUser() async throws{
        isBlocked = false
        try await UserManager.shared.unBlockUser(uid: currentUser.id, targetUid: user.id)
        currentUser.blockedIds.removeAll(where: {$0 == user.id})

    }
    
    func unBlockUser(targetUid: String) async throws{
       
        currentUser.blockedIds.removeAll(where: {$0 == user.id})
        blockedUsers.removeAll(where: {$0.id == user.id})
        try await UserManager.shared.unBlockUser(uid: currentUser.id, targetUid: targetUid)
       

    }
    
    func muteUser() async throws{
        currentUser.mutedIds.append(user.id)
        try await UserManager.shared.muteUser(uid: currentUser.id, targetUid: user.id)
        isMuted = true
        
        
    }
    
    func hideContent(contentId: String) async throws{
        
        try await UserManager.shared.hideContent(uid: currentUser.id, contentId: contentId)
        currentUser.hiddenPostIds.append(contentId)
        
    }
    
    func unHideContent(contentId: String) async throws{
        
        currentUser.hiddenPostIds.removeAll(where: {$0 == contentId})
        try await UserManager.shared.unHideContent(uid: currentUser.id, contentId: contentId)
        
        
    }
    
    func unMuteUser() async throws{
        isMuted = false
        try await UserManager.shared.unMuteUser(uid: currentUser.id, targetUid: user.id)
        currentUser.mutedIds.removeAll(where: {$0 == user.id})
    }
    
    func checkBlockAndMute(){
        if currentUser.blockedIds.contains(user.id){
            isBlocked = true
        }
        if currentUser.mutedIds.contains(user.id){
            isMuted = true
        }
        if user.blockedIds.contains(currentUser.id){
            youAreBlocked = true
        }
    }
    
    
    func sendReport(reportCategory: ReportCategory, contentCategory: ContentCategoryEnum, contentId: String?, text: String? = nil) async throws{
        
        let reportId = UUID().uuidString
        let report = Report(id: reportId, contentCategory: contentCategory.rawValue, category: reportCategory.rawValue, postId: contentId, reportedUserId: user.id, reportingUserId: currentUser.id, text: text)
        
        try await UserManager.shared.sendReport(report: report)
        if contentCategory == .post, let contentId = contentId{
            try await PostManager.shared.updateReportNumber(postId: contentId)
        }else if contentCategory == .listing, let contentId = contentId{
            try await ListingManager.shared.updateReportNumber(listingId: contentId)
        }
        
    }
    
    func deleteContent(contentId: String?, contentCategory: ContentCategoryEnum) async throws{
        
        if contentCategory == .post, let contentId = contentId{
            
            try await PostManager.shared.deletePost(postId: contentId)
            allPosts.removeAll(where: {$0.id == contentId})
        }else if contentCategory == .listing, let contentId = contentId{
            
            try await ListingManager.shared.removeListing(listingId: contentId)
        }
    }
    
    func isUsernameAvailable(username: String) async throws -> Bool{
        return try await UserManager.shared.checkUsernameAvailability(userId: user.id, username: username)
    }
    
    
    func updateUsername(username: String) async throws{
        try await UserManager.shared.updateUsername(userId: currentUser.id, username: username)
    }
    
    func updateFirstName(firstName: String) async throws{
        try await UserManager.shared.updateFirstName(uid: currentUser.id, firstName: firstName)
    }
    
    func updateLastName(lastName: String) async throws{
        try await UserManager.shared.updateLastName(uid: currentUser.id, lastName: lastName)
    }
    
    func updateBio(bio: String) async throws{
        try await UserManager.shared.updateBio(uid: currentUser.id, bio: bio)
    }
    
    func editCaption(caption: String, postId: String) async throws{
        try await PostManager.shared.updateCaption(postId: postId, caption: caption)
    }
    
    
    func validateUsername(_ username: String) -> UsernameValidationError {
        // Check if the username is between 4 and 20 characters long
        if username.count < 4 {
            return .tooShort
        }
        
        if username.count > 20 {
            return .tooLong
        }
        
        // Regular expression to check for allowed characters (alphanumeric, dashes, and underscores)
        let regex = "^[a-zA-Z0-9_-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        if !predicate.evaluate(with: username) {
            return .invalidCharacters
        }
        
        return .valid
    }
    
    
    func fetchSavedPosts(fetchSteps: Int) async throws{
        
        let remainingPosts = savedPostIds.count - savedPostIndex
        if remainingPosts < 1 { return }
        let newIndex = savedPostIndex + min(remainingPosts, fetchSteps)
        
        for index in savedPostIndex..<newIndex{
            
            do{
                let postId = savedPostIds[index]
                var fetchedPost = try await PostManager.shared.getPost(postId: postId)
                try await fetchedPost.setUserOwner()
                savedPosts.append(fetchedPost)
            }catch{
                continue
            }
        }
        
        savedPostIndex = newIndex
        
    }
    
    
    
    
    func fetchNeighborUsers() async throws{
        if lastDocumentUserNeighbor == nil && usersNeighbor.count > 0 {return}
        
        Task{
            if let location = userLocation{
                let fetchedUsers = try await UserManager.shared.getUsersByLocation(location: location, count: 20, lastDocument: lastDocumentUserNeighbor)
                lastDocumentUserNeighbor = fetchedUsers.lastDocument
                usersNeighbor.append(contentsOf: fetchedUsers.output)
            }
        }
    }
    
    
    var userLocation : CLLocationCoordinate2D? {
        if let geoPoint = user.location{
            return convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
        }else{
            return nil
        }
        
    }
    
    func convertGeoPointToCLLocationCoordinate2D(geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    
    func getBlockedUsers(blockedUserIds: [String]) async throws{
        
        
        for userId in blockedUserIds{
            
            do{
                let user = try await UserManager.shared.getUser(userId: userId)
                blockedUsers.append(user)
            }catch{
                continue
            }
        }
    }
    
}
