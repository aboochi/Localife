//
//  StoryPerUserViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/7/24.
//


import Foundation
import FirebaseFirestore
import AVFoundation

@MainActor
final class StoryPerUserViewModel: ObservableObject{
    @Published var stories: [Story] = []
    var lastDocument: DocumentSnapshot?
    @Published var user: DBUser
    
    init(user: DBUser){
        self.user = user
        Task{
            
            try await fetchStories()
        }
    }
    
    func fetchStories() async throws{
        
        if stories.count > 0 && lastDocument == nil{ return}
           
        let fetchResult = try await PostManager.shared.getUserStoriesByTime(uid: user.id, count: 20, lastDocument: lastDocument)
        lastDocument = fetchResult.lastDocument
        //save posts locally
        try await fetchAndsetStoryOwner(FetchedStories: fetchResult.output)
        try await saveStoriesLocally()
        
    }
    
    
    
    func fetchAndsetStoryOwner(FetchedStories: [Story]) async throws{
        for var story in FetchedStories{
            do{
                try await story.setUserOwner()
                if story.user != nil{
                    self.stories.append(story)
                }
            } catch{
                continue
            }
        }
    }
    
    
    

    
    
// MARK - SAVE VIDEO AND IMAGES LOCALLY
    
  
    func saveStoriesLocally() async throws{
        for story in stories{
            guard let url = story.videoUrl else {continue}
                if url.contains("storyVideos"){
                    guard let urlObject = URL(string: url) else {continue}
                    let path = "\(story.id)-video\(index)"
                    if FileManagerHelper.shared.checkFileExists(path: path) == nil{
                        _ = try await FileManagerHelper.shared.downloadAndSaveMedia(from: urlObject, path: path)

                    }
                }
            
        }
    }
    

}

