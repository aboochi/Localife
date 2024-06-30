//
//  MediaSlideView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/12/24.
//

enum MediumCategory: String{
    case post = "post"
    case story = "story"
    case listing = "listing"
    case message = "message"
}

import SwiftUI
import AVFoundation
import Kingfisher


struct MediaSlidePresenter: View{
    
    let urls: [String]
    let id: String
    let aspectRatio: CGFloat
    let mediumCategory: MediumCategory
    let width : CGFloat = UIScreen.main.bounds.width
    
    @Binding var appearedPostIndecis: [Int]
    @Binding var playedPostIndex: Int
    let currentItemIndex: Int
    
    var body: some View{
        
        if appearedPostIndecis.contains(currentItemIndex){
            VStack{
                if urls.count > 1{
                    MediaSlideView(urls: urls, id: id, aspectRatio: aspectRatio, mediaCategory: mediumCategory , playedPostIndex: $playedPostIndex, postIndex: currentItemIndex )
                }else{
                    MediaSingleSlideView(id: id, index: 0, url: urls[0], aspectRatio: aspectRatio, width: width, mediumCategory: mediumCategory , playedPostIndex: $playedPostIndex , postIndex: currentItemIndex, slideIndex: 0 ,currentSlide: .constant(0) )
                }
            }
            
            
        }else{
            
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 400)
        }
    }
}


struct MediaSlideView: View{
    
    let urls: [String]
    let id: String
    let aspectRatio: CGFloat
    let mediaCategory: MediumCategory
    @State var currentPage: Int = 0
    @Binding var playedPostIndex: Int
    let postIndex: Int
    
    let width = UIScreen.main.bounds.width
    
    var body: some View{
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                    
                    GeometryReader{ geo in
                        ZStack{
                            
                            if index == currentPage || index == currentPage + 1 || index == currentPage - 1{
                                MediaSingleSlideView(id: id, index: index, url: url, aspectRatio: aspectRatio, width: width, mediumCategory: mediaCategory , playedPostIndex: $playedPostIndex, postIndex: postIndex, slideIndex: index ,currentSlide: $currentPage )
                                
                            } else{
                                Rectangle()
                                    .foregroundColor(.white)
                                    .frame(width: width, height: width / max(aspectRatio, 0.65))
                            }
                            
                        }
                        
                        .onChange(of: geo.frame(in: .global)) { oldValue, newValue in
                            
                            
                            if newValue.midX < 0 {
                                if currentPage == index{
                                    currentPage+=1
                                }
                                
                            } else if newValue.midX > geo.size.width {
                                if currentPage == index{
                                    currentPage-=1
                                }
                            }
                        }
                        
                    }
                }
                .frame(width: width, height: width / max(aspectRatio, 0.65))
                
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .scrollTargetBehavior(.paging)
        .overlay{
            VStack{
                Spacer()
                slideIndicatorView(index: $currentPage, numberOfSlides: urls.count)
                    .padding(.bottom, 7)
                
            }
            
        }
        
    }
}





struct MediaSingleSlideView: View {
    let id: String
    let index: Int
    let url: String
    let aspectRatio: CGFloat
    let width: CGFloat
    let mediumCategory: MediumCategory
    var savingPath: String {return "\(id)/-\(mediumCategory.rawValue)-video\(index)"}
    @Binding var playedPostIndex: Int
    let postIndex: Int
    let slideIndex: Int
    @Binding var currentSlide: Int
    
    var body: some View{
        
        ZStack{
            
            if url.contains("Image"){
                
                DisplayImageItemView(aspectRatio: aspectRatio, width: width, url: url)
                
            }else if url.contains("Video"){
                
                DisplayVideoItemView(aspectRatio: aspectRatio, width: width, savingPath: savingPath, url: url, playedPostIndex: $playedPostIndex, postIndex: postIndex, slideIndex: slideIndex, currentSlide: $currentSlide)
                
            }
        }
        .frame(width: width, height: width / max(aspectRatio, 0.65))
        
    }
}


struct DisplayImageItemView: View{
    
    let aspectRatio: CGFloat
    let width: CGFloat
    let url: String
    
    var body: some View{
        
        ZStack{
            KFImage(URL(string: url))
            
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width / aspectRatio)
            
        }
    }
}



struct DisplayVideoItemView: View {
    
    let aspectRatio: CGFloat
    let width: CGFloat
    let savingPath: String
    let url: String
    @Binding var playedPostIndex: Int
    let postIndex: Int
    let slideIndex: Int
    @Binding var currentSlide: Int
    @State var isPlaying: Bool = true
    @State var isMuted: Bool = true

    
    var body: some View {
        
        ZStack {
            
            if let localUrl = FileManagerHelper.shared.checkFileExists(path: savingPath) {
                let player = AVPlayer(url: localUrl)
                VideoPlayerWrapper1(url: localUrl, aspectRatio: aspectRatio , postIndex: postIndex, slideIndex: slideIndex, playedPostIndex: $playedPostIndex, currentSlide: $currentSlide, isPlaying: $isPlaying, isMute: $isMuted)
                    .scaleEffect(max(1, 0.65/aspectRatio))
                    .frame(width: width, height: width / max(aspectRatio, 0.65))
                    .clipped()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            player.play()
                        }
                    }
                    .overlay(muteButton  ,alignment: .bottomTrailing)
                    .overlay(playButton,  alignment: .center)
                
            } else {
                if let url = URL(string: url) {
                    let player = AVPlayer(url: url)
                    VideoPlayerWrapper1(url: url, aspectRatio: aspectRatio , postIndex: postIndex, slideIndex: slideIndex, playedPostIndex: $playedPostIndex, currentSlide: $currentSlide, isPlaying: $isPlaying, isMute: $isMuted)
                        .frame(width: width, height: width / aspectRatio)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                player.play()
                            }
                        }
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
        .padding(3)
        .background(.gray)
        .clipShape(Circle())
        .padding(5)
        
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
    
    
    
    
    @ViewBuilder
    var playButton1: some View{
        
        Button(action: {
            
            
        }, label: {
            Image(systemName: "play.fill")
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


