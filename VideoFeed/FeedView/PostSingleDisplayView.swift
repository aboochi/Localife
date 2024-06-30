//
//  PostSlideSingleView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/3/24.
//


import SwiftUI
import Kingfisher
import AVKit

struct PostSingleDisplayView: View {
  
    
    @EnvironmentObject var session: AuthenticationViewModel

    let post: Post
    let index: Int
    let screenWidth = UIScreen.main.bounds.width
    var key: String {return "\(post.id)/-\(index)"}
    @Binding var playedPostIndex: Int
    let postIndex: Int
    @Binding var currentPage: Int
    
    @State var isPlaying = true
    @State var isMuted = false



    
    
    var body: some View {
        ZStack{
            
           
                ZStack{
                    
                    if post.urls[index].contains("postImages"){
                        
                        ImageDisplay()
                        
                    }else if post.urls[index].contains("postVideos"){
                        
                        
                        VideoDisplay()
                        
                    }
                       
                }
             
     
        }
        .frame(width: screenWidth, height: screenWidth / max(post.aspectRatio, 0.65))

    }
    
    
    
    @ViewBuilder
    func ImageDisplay() -> some View{
        
        ZStack{
            KFImage(URL(string:  post.urls[index])!)
                .blur(radius: session.dbUser.hiddenPostIds.contains(post.id) ? 70 : 0)
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth, height: screenWidth / post.aspectRatio)
         
        }
    }
    
    
    @ViewBuilder
    func VideoDisplay() -> some View{
        
        ZStack {
            let path = "\(post.id)-video\(index)"
            if let localUrl = FileManagerHelper.shared.checkFileExists(path: path) {
               
                VideoPlayerWrapper1(url: localUrl, aspectRatio: post.aspectRatio , postIndex: postIndex, slideIndex: index, playedPostIndex: $playedPostIndex, currentSlide: $currentPage, isPlaying: $isPlaying, isMute: $isMuted)
                    .blur(radius: session.dbUser.hiddenPostIds.contains(post.id) ? 70 : 0)
                    .scaleEffect(max(1, 0.65/post.aspectRatio))
                    .frame(width: screenWidth, height: screenWidth / max(post.aspectRatio, 0.65))
                    .clipped()
                    .contentShape(Rectangle()) // Confines the tap area to a rectangle
                    .overlay(muteButton  ,alignment: .bottomTrailing)
                    .overlay(playButton,  alignment: .center)
                
                    
              
          
                    
            } else {
                if let url = URL(string: post.urls[index]) {
                    
                    VideoPlayerWrapper1(url: url, aspectRatio: post.aspectRatio , postIndex: postIndex, slideIndex: index, playedPostIndex: $playedPostIndex, currentSlide: $currentPage, isPlaying: $isPlaying , isMute: $isMuted)
                        .blur(radius: session.dbUser.hiddenPostIds.contains(post.id) ? 70 : 0)
                        .frame(width: screenWidth, height: screenWidth / max(post.aspectRatio, 0.65))
                        .clipped()
                        .contentShape(Rectangle()) // Confines the tap area to a rectangle
                        .overlay(muteButton  ,alignment: .bottomTrailing)
                        .overlay(playButton,  alignment: .center)
                            
               
                }
            }
        }
        
    }
    
   
    
    @ViewBuilder
    var muteButton: some View{
        
        Button(action: {
            isMuted.toggle()
            
            print("player is muted: \(isMuted)")
        }, label: {
            Image(systemName: isMuted ?  "speaker.slash.fill" : "speaker.wave.2.fill")
        })
        .foregroundColor(.white)
        .padding(5)
        .background(.gray)
        .clipShape(Circle())
        .padding(7)
        
    }
    
    
    @ViewBuilder
    var playButton: some View{
        
        Button(action: {
            isPlaying = true
            
        }, label: {
            Text("Watch again")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isPlaying ? .clear : .black)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(.white.opacity(isPlaying ? 0.0 : 0.6))
                .clipShape(Capsule())
                
        })
        .disabled(isPlaying)
    }
    

}




