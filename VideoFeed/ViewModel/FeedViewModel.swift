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
    
    var lastDocument: DocumentSnapshot?
    var user: DBUser
    var MessageviewModel: MessageViewModel
    var storyViewModel = StoryViewModel()

    
    init(user: DBUser){
        self.user = user
        self.MessageviewModel = MessageViewModel(user: user)
        
    }
    
    func updateUser(_ user: DBUser){
        self.user = user
    }
    
    
    
    
    func fetchPost(lastTime: Timestamp) async throws{
        

        if lastDocument == nil && posts.count > 0{
            
            print("satisfied")

            return
        }
        
        do{
            let fetchResult = try await PostManager.shared.getPostsByTime(count: 10, lastTime: lastTime, lastDocument: lastDocument)
            lastDocument = fetchResult.lastDocument
            //print("posts: >>>>>>>>>>>>>>>>>> \(fetchResult.output.count)")
            //save posts locally
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
        //print("number of fetch posts before filtering >>>>>>>>  \(fetchedPosts.count)")
        let shuffledPosts = fetchedPosts.shuffled()
        for var post in shuffledPosts{
            do{
                try await post.setUserOwner()
                
                if let userOwner = post.user, !user.hiddenPostIds.contains(post.id), !user.blockedIds.contains(post.ownerUid), !userOwner.blockedIds.contains(user.id), post.ownerUid != user.id{
                    self.posts.append(post)
                }
            } catch{
                continue
            }
        }
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
