//
//  FeedViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/30/24.
//

import Foundation
import FirebaseFirestore
import AVFoundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject{
    
    @Published var posts: [Post] = []
    @Published var playerItemDict: [String: AVPlayerItem] = [:]
    @Published var playerDict: [String: AVPlayer] = [:]
    @Published var playedPostIndex: Int = 0
    
    var lastNewDocument: DocumentSnapshot?
    var lastOldDocument: DocumentSnapshot?
    @Published var lastDocument: DocumentSnapshot?


    var user: DBUser
    var MessageviewModel: MessageViewModel
    var storyViewModel = StoryViewModel()
    
    var previousNewScore : Int
    var tempOldScore: Int

    
    init(user: DBUser){
        
        self.user = user
        self.MessageviewModel = MessageViewModel(user: user)
        previousNewScore = user.firstSeenPostScore
        tempOldScore = user.lastSeenPostScore
        setSeenrecord()
        
        
    }
    
    func updateUser(_ user: DBUser){
        self.user = user
    }
    
    func updateUser() async throws{
        let newUser = try await UserManager.shared.getUser(userId: user.id)
            self.user = newUser
        
    }
    
    
    
    func setSeenrecord(){
        
        let currentTime: Int = Int(Date().timeIntervalSince1970)
        let oneDay = 86400
        previousNewScore = user.firstSeenPostScore
        if user.firstSeenPostScore < currentTime - oneDay*5{
            user.firstSeenPostScore = currentTime - oneDay*5
            tempOldScore = currentTime - oneDay*5
        }
        
    }
    
    func fetchNewPost(refresh: Bool) async throws{
        
       print("user.firstSeenPostScore: >>>>>>>>>>>>>>>>  \(user.firstSeenPostScore)")
       // if lastNewDocument == nil && posts.count > 0{return}
        
        do{
            let fetchResult = try await PostManager.shared.getNewPosts(highestScore: user.firstSeenPostScore, count: 10, lastDocument: nil)
            lastDocument = fetchResult.lastDocument
            if fetchResult.output.count < 1{
                try await fetchOldPost(refresh: refresh)
            }else{
                if refresh{
                    posts = []
                }
                try await fetchAndsetPostOwner(fetchedPosts: fetchResult.output)
                try await savePostsLocally()
            }
        }catch{
            print("failed to fetch >>>>>>> \(error)")
        }
    }
    
    func fetchOldPost(refresh: Bool) async throws{
        

       // if lastNewDocument == nil && posts.count > 0{return}
        print("user.lastSeenPostScore: >>>>>>>>>>>>>>>>  \(user.lastSeenPostScore)")

        var oldestScore: Int { if previousNewScore < tempOldScore{
            return tempOldScore}else{
                return user.lastSeenPostScore
            }
        }
        do{
            let fetchResult = try await PostManager.shared.getOldPosts(lowestScore: oldestScore, count: 10, lastDocument: nil)
            lastDocument = fetchResult.lastDocument
            if fetchResult.output.count > 1 && refresh{
                posts = []
            }
            try await fetchAndsetPostOwner(fetchedPosts: fetchResult.output)
            try await savePostsLocally()
            
        }catch{
            print("failed to fetch >>>>>>> \(error)")
        }
    }
    
    func fetchPostById( postId: String) async throws{
        var post = try await PostManager.shared.getPost(postId: postId)
        post.user = user
        posts.insert(post, at: 0)
    }
    
    func fetchAndsetPostOwner( fetchedPosts: [Post]) async throws{
        
        
        for var post in fetchedPosts{
            do{
                try await post.setUserOwner()
                
                if let userOwner = post.user, !user.hiddenPostIds.contains(post.id), !user.blockedIds.contains(post.ownerUid), !userOwner.blockedIds.contains(user.id), post.ownerUid != user.id, !posts.contains(post){
                    self.posts.append(post)
                    print("user.firstSeenPostScore >>>>>>>>>>>.\(user.firstSeenPostScore)   post score:   \(post.score)   user.lastSeenPostScore: \(user.lastSeenPostScore)")
                    tempOldScore = min(tempOldScore, post.score)
                    user.firstSeenPostScore = max(user.firstSeenPostScore, post.score)
                    user.lastSeenPostScore = min(user.lastSeenPostScore, post.score)
                    
                }
            } catch{
                continue
            }
        }
        try await UserManager.shared.updateLastSeenPost(uid: user.id, score: user.lastSeenPostScore)
        try await UserManager.shared.updateFirstSeenPost(uid: user.id, score: user.firstSeenPostScore)

    }
    
    func getSavedPostIds() async throws -> [String]{
        
        try await UserManager.shared.getSavedPostIdsByTime(userId: user.id)
    }
    
    func getSeenPostIds() async throws -> [String]{
        
        try await UserManager.shared.getSeenPostIds(userId: user.id)
    }
    
    func addPostSeen(postId: String) async throws{
        
        try await UserManager.shared.addSeenPost(userId: user.id, postId: postId)
    }
    
    func getSavedListingIds() async throws -> [String]{
        
        try await UserManager.shared.getSavedListingIdsByTime(userId: user.id)
    }
 
// MARK - SAVE VIDEO AND IMAGES LOCALLY
    
  
    func savePostsLocally() async throws{
        for post in posts{
            for (index, url) in post.urls.enumerated(){
                if url.contains("postVideos"){
                    guard let urlObject = URL(string: url) else {continue}
                    let path = "\(post.id)-video\(index)"
                    if FileManagerHelper.shared.checkFileExists(path: path) == nil{
                        _ = try await FileManagerHelper.shared.downloadAndSaveMedia(from: urlObject, path: path)

                    }
                }
            }
        }
    }
    
    
    func getFollowerIds() async throws -> [String]{
        
        return try await UserManager.shared.getFollowerIds(userId: user.id)
        
    }
    
    func getFollowingIds() async throws -> [String]{
        
        return try await UserManager.shared.getFollowingIds(userId: user.id)
        
    }
    
    func getRequestIds() async throws -> [String]{
        
        return try await UserManager.shared.getRequestIds(userId: user.id)
        
    }
   
}


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        var chunks: [[Element]] = []
        for i in stride(from: 0, to: self.count, by: size) {
            let chunk = Array(self[i..<Swift.min(i + size, self.count)])
            chunks.append(chunk)
        }
        return chunks
    }
}
