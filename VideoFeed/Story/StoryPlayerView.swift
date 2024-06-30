//
//  StoryPlayerView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/8/24.
//

import SwiftUI
import AVFoundation
import Kingfisher

struct StoryPlayerView: View {
    let story: Story
    @State var player: AVPlayer?
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        
        if let videoUrl = story.videoUrl, videoUrl != ""{
            
            ZStack {
                let path = "\(story.id)-video\(index)"
                if let localUrl = FileManagerHelper.shared.checkFileExists(path: path) {
                    
                    
                    let player = AVPlayer(url: localUrl)
                    myVideoPlayer(player: player)
                        .scaleEffect(1)
                        .frame(width: screenWidth, height: screenWidth / story.aspectRatio)
                        .clipped()
                        .onAppear {
                            Task{
                                
                                try await loadPlayerItem(videoURL: localUrl)
                                player.play()
                            }
                        }
                } else {
                    
                    OptionalVideoPlayer(player: player)
                                .frame(width: screenWidth, height: screenWidth / story.aspectRatio)
                                .onAppear {
                                    Task{
                                        
                                        Task {
                                            

                                            player = AVPlayer()

                                            guard let videoURL = URL(string: videoUrl) else { return}
                                            try await loadPlayerItem(videoURL: videoURL)
                                            
                                             player?.isMuted = true
                                             player?.play()
                                            
                                            
                                        }

                                        
                                    }
                                }
                              
                        }
                   
                }
            
            
            
        
            
            
            
            
        } else {
            
                KFImage(URL(string: story.imageUrl))
                    .resizable()
                    .frame(width: screenWidth, height: screenWidth / story.aspectRatio)
                    .alignmentGuide(HorizontalAlignment.center) { _ in
                        screenWidth / 2 // Center the image horizontally
                    }
   
        }
            
        }

        
        
    func loadPlayerItem(videoURL: URL) async throws {
        let asset = AVAsset(url: videoURL)
        do {
            let (_, _, _) = try await asset.load(.tracks, .duration, .preferredTransform)
        } catch {
            print(error.localizedDescription)
        }
        let item = AVPlayerItem(asset: asset)
        DispatchQueue.main.async {
            
            self.player?.replaceCurrentItem(with: item)
        }
       
    }
        
        
     
    @ViewBuilder
    func OptionalVideoPlayer(player: AVPlayer?) -> some View{
        
        if let player = player{
             myVideoPlayer(player: player)
        }else{
            
            KFImage(URL(string: story.imageUrl))
                .resizable()
                .frame(width: screenWidth, height: screenWidth / story.aspectRatio)
                .alignmentGuide(HorizontalAlignment.center) { _ in
                    screenWidth / 2 // Center the image horizontally
                }
        }
    }
    
}



