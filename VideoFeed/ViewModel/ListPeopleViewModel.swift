//
//  ListPeopleViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/24/24.
//

import Foundation
import FirebaseFirestore
import CoreLocation

enum UserTypeEnum{
    case follower
    case following
    case neighbor
    case postLiker
    case commentLiker
    case replyLiker
    case questionLiker
    case questionReplyLiker
}

@MainActor
final class ListPeopleViewModel: ObservableObject{
    
    
    var lastDocumentFollowers: DocumentSnapshot?
    var lastDocumentFollowing: DocumentSnapshot?
    var lastDocumentUserNeighbor: DocumentSnapshot?
    var lastDocumentPostLikers: DocumentSnapshot?
    var lastDocumentCommentLikers: DocumentSnapshot?
    var lastDocumentReplyLikers: DocumentSnapshot?
    var lastDocumentQuestionLikers: DocumentSnapshot?
    var lastDocumentQuestionReplyLikers: DocumentSnapshot?


    
    @Published var followerIds: [String] = []
    @Published var followingIds: [String] = []
    @Published var postLikersIds: [String] = []
    @Published var commentLikersIds: [String] = []
    @Published var replyLikersIds: [String] = []
    @Published var questionLikersIds: [String] = []
    @Published var questionReplyLikersIds: [String] = []

    
    
    @Published var followers: [DBUser] = []
    @Published var followings: [DBUser] = []
    @Published var neighbors: [DBUser] = []
    @Published var postLikers: [DBUser] = []
    @Published var commentLikers: [DBUser] = []
    @Published var replyLikers: [DBUser] = []
    @Published var questionLikers: [DBUser] = []
    @Published var questionReplyLikers: [DBUser] = []

    
    let currentUser: DBUser
    let user: DBUser

    
    
    init(currentUser: DBUser,  user: DBUser){
        
        self.currentUser =  currentUser
        self.user =  user

    }
    
    
    func follow(currentUser: DBUser, user: DBUser) async throws{
       
        
       
        try await UserManager.shared.addFollower(followerId: currentUser.id, followedId: user.id)
        
    }
    
    func request(currentUser: DBUser, user: DBUser) async throws{
     
        try await UserManager.shared.addRequest(followerId: currentUser.id, followedId: user.id)
        
    }
    
    func unfollow(currentUser: DBUser, user: DBUser) async throws{
       
        
        try await UserManager.shared.removeFollower(followerId: currentUser.id, followedId: user.id)
       
    }
    
    func removefollower(followerId: String, followedId: String) async throws {
        try await UserManager.shared.removeFollower(followerId: followerId, followedId: followedId)
    }
    
    func acceptRequest(currentUser: DBUser, userId: String) async throws {
        try await UserManager.shared.addFollower(followerId: userId, followedId: currentUser.id)
    }
    
    
    
    func getFollowers() async throws {
        if followerIds.count > 0 && lastDocumentFollowers == nil{ return }
        let results = try await UserManager.shared.getFollowersIdByTime(userId: user.id, count: 10, lastDocument: lastDocumentFollowers)
        lastDocumentFollowers = results.lastDocument
        followerIds.append(contentsOf: results.output)
        try await getUsers(userIds: results.output, userType: .follower)

       
    }
    
    func getFollowing() async throws {
        if followingIds.count > 0 && lastDocumentFollowing == nil{ return }
        let results = try await UserManager.shared.getFollowingIdByTime(userId: user.id, count: 10, lastDocument: lastDocumentFollowing)
        lastDocumentFollowing = results.lastDocument
        followingIds.append(contentsOf: results.output)
        try await getUsers(userIds: results.output, userType: .following)
    }

    
    
    func getNeighbors() async throws{
        if lastDocumentUserNeighbor == nil && neighbors.count > 0 {return}
        
        Task{
            if let location = userLocation{
                let fetchedUsers = try await UserManager.shared.getUsersByLocation(location: location, count: 20, lastDocument: lastDocumentUserNeighbor)
                lastDocumentUserNeighbor = fetchedUsers.lastDocument
                neighbors.append(contentsOf: fetchedUsers.output)
            }
        }
    }
    
    
    func getPostLikers(postId: String) async throws {
        if postLikersIds.count > 0 && lastDocumentPostLikers == nil{ return }
        let results = try await PostManager.shared.getLikersIdByTime(postId: postId, count: 10, lastDocument: lastDocumentPostLikers)
        lastDocumentPostLikers = results.lastDocument
        postLikersIds.append(contentsOf: results.output)
        try await getUsers(userIds: results.output, userType: .postLiker)
    }
    
    func getCommentLikers(comment: Comment) async throws {
        if commentLikersIds.count > 0 && lastDocumentCommentLikers == nil{ return }
        
        let results = try await PostManager.shared.getCommentLikersIdByTime(postId: comment.postId, commentId: comment.id, count: 10, lastDocument: lastDocumentCommentLikers)
        lastDocumentCommentLikers = results.lastDocument
        commentLikersIds.append(contentsOf: results.output)
        try await getUsers(userIds: results.output, userType: .commentLiker)
    }
    
    func getReplyLikers(reply: Comment) async throws {
        if replyLikers.count > 0 && lastDocumentReplyLikers == nil{ return }
        
        if let commentId = reply.parentCommentId{
            let results = try await PostManager.shared.getReplyLikersIdByTime(postId: reply.postId, commentId: commentId, replyId: reply.id, count: 10, lastDocument: lastDocumentReplyLikers)
            lastDocumentReplyLikers = results.lastDocument
            postLikersIds.append(contentsOf: results.output)
            try await getUsers(userIds: results.output, userType: .replyLiker)
        }
    }
    
    
    func getQuestionLikers(question: Question) async throws{
        
        if questionLikers.count > 0 && lastDocumentQuestionLikers == nil{ return }
        
        let results = try await ListingManager.shared.getQuestionLikersIdByTime(listingId: question.listingId, questionId: question.id, count: 10, lastDocument: lastDocumentQuestionLikers)
        lastDocumentQuestionLikers = results.lastDocument
        questionLikersIds.append(contentsOf: results.output)
        try await getUsers(userIds: results.output, userType: .questionLiker)
    }
    
    func getQuestionReplyLikers(reply: Question) async throws{
        
        if questionReplyLikers.count > 0 && lastDocumentQuestionReplyLikers == nil{ return }
        
        if let questionId = reply.parentQuestionId{
            
            let results = try await ListingManager.shared.getReplyLikersIdByTime(listingId: reply.listingId, questionId: questionId , replyId: reply.id, count: 10, lastDocument: lastDocumentQuestionReplyLikers)
            
            lastDocumentQuestionReplyLikers = results.lastDocument
            questionReplyLikersIds.append(contentsOf: results.output)
            try await getUsers(userIds: results.output, userType: .questionReplyLiker)
        }
    }
    
    
    
    func getUsers(userIds: [String], userType: UserTypeEnum) async throws{
        for userId in userIds{
            
            do{
                let user = try await UserManager.shared.getUser(userId: userId)
                let updatedUser = try await setFollowingStatus(targetUser: user)
                
                switch userType {
                case .follower:
                    followers.append(updatedUser)
                case .following:
                    followings.append(updatedUser)
                case .neighbor:
                    neighbors.append(updatedUser)
                case .postLiker:
                    postLikers.append(updatedUser)
                case .commentLiker:
                    commentLikers.append(updatedUser)
                case .replyLiker:
                    replyLikers.append(updatedUser)
                case .questionLiker:
                    questionLikers.append(updatedUser)
                case .questionReplyLiker:
                    questionReplyLikers.append(updatedUser)
                }
            }catch{
                continue
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
    
    
    func setFollowingStatus(targetUser: DBUser) async throws -> DBUser{
        let followedByYou = try await UserManager.shared.checkfollow(followerId: currentUser.id, followedId: targetUser.id)
        let followingYou  = try await UserManager.shared.checkfollow(followerId: targetUser.id, followedId: currentUser.id)
        let youRequested  = try await UserManager.shared.checkRequest(followerId: currentUser.id, followedId: targetUser.id)
        var outputUser = targetUser
        outputUser.followedByYou = followedByYou
        outputUser.followingYou = followingYou
        outputUser.youRequested = youRequested
        
        return outputUser


    }
    
    
    
    
}
