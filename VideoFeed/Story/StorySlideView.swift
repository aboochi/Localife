//
//  StorySlideView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/7/24.
//

import SwiftUI
import Kingfisher
import AVFoundation


struct StorySlideView: View {
    @State var slideIndex : Int = 0
    @State var slideProgress: Int = 0
    
    @StateObject var viewModel : StoryPerUserViewModel
    @Binding var currentUserIndex: Int
    let userIndex: Int
    let screenWidth =  UIScreen.main.bounds.width
    //@State var pauseTimer: Bool = false
    @State private var isPressed = false
    @Binding var isScrolling: Bool

    var body: some View {
        VStack{
            ScrollViewReader { proxy in
                ScrollView(.horizontal){
                    HStack(alignment: .center, spacing: 0){
                        ForEach(Array(viewModel.stories.enumerated()), id: \.offset ){ index, story in
                            if index == slideIndex || index == slideIndex - 1 || index == slideIndex + 1{
                                StoryPlayerView(story: story)
                                    .id(index)
                                 
                                
                            } else{
                                Color.black
                                    .frame(width: screenWidth, height: screenWidth / story.aspectRatio)

                            }
                        }
                     
                        
                    }
                    .background(
                        ZStack{
                        
                            if userIndex == currentUserIndex{
                                Color.clear
                                    .onAppear{
                                        
                                        if !isScrolling {
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                                                isScrolling = true
                                            }
                                        }
                                        slideProgress = 0
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
                                            addNumberEveryMillisecond(initialNumber: $slideProgress, stopAt: 500)

                                        }
                                    }
                            }
                        }
                        
                    )
   
                    .onChange(of: slideIndex) { _, newValue in
                        
                        proxy.scrollTo(newValue, anchor: .center)
                        
                        slideProgress = 0
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
                            addNumberEveryMillisecond(initialNumber: $slideProgress, stopAt: 500)

                        }
                    }
                    .onChange(of: slideProgress) { oldValue, newValue in
                        if slideProgress == 500{
                            if slideIndex < viewModel.stories.count - 1{
                                slideIndex += 1
                                print("current user index: \(currentUserIndex)")
                            } else{
                                isScrolling = false
                                currentUserIndex += 1
       
                            }
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
          
                .disabled(true)
                
                
                .onAppear{
                    print("story: \(userIndex)  current index: \(currentUserIndex)")
                }
                .onDisappear{
                    print("story: \(userIndex)  dis appeared")
                }
                
                
            }
            .overlay(
                VStack{
                    storyProgressBar
                        .padding(.top, 10)
                        .padding(.horizontal, 4)
                    
                    nextSlideButtons
                    
                    
                }
                
            )
        }
        
       
    }
    
    var nextSlideButtons: some View{
        
        HStack{
            
            
            Color.white.opacity(0.01)
                .frame(width: screenWidth/2)//, height: screenWidth / 0.57)
                .onTapGesture {
                    
                    if slideIndex > 0{
                        slideIndex -= 1
                    }
                }
            
            
            Color.white.opacity(0.01)
                .frame(width: screenWidth/2)//, height: screenWidth / 0.57)
                .onTapGesture {
                    slideProgress = 500
                    
                }
            
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ _ in
                            isPressed = true
                        })
                        .onEnded({ _ in
                            isPressed = false
                        })
                )
            
                .onChange(of: isPressed) { oldValue, newValue in
                    print("pause timer: \(oldValue)    \(newValue)")
                }
        }
        
        
    }
    
    var storyProgressBar: some View{
        HStack(spacing: 2){
            ForEach(Array(viewModel.stories.enumerated()), id: \.offset ){ index, story in
                
                
                Rectangle()
                    .frame( height: 3)
                    .foregroundColor(index < slideIndex ? .white : .white.opacity(0.5))
                    .cornerRadius(1)
                    .shadow(color: .black, radius: 3)
                    .background(
                        GeometryReader{ geo in
                            Color.clear
                                .overlay(
                                    Rectangle()
                                        .frame( width: index == slideIndex ? geo.size.width * (CGFloat(slideProgress) / CGFloat(500)): 0, height: 3)
                                        .foregroundColor(.white)
                                        .cornerRadius(1)
                                    , alignment: .leading
                                )
                        }
                    )
                
            }
        }
    }
    
    @discardableResult
    func addNumberEveryMillisecond(initialNumber: Binding<Int>, stopAt: Int) -> Timer {
        let interval = 0.02
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            
            guard !isPressed else { return }
            
            
            initialNumber.wrappedValue = initialNumber.wrappedValue + 1
            
            
            if initialNumber.wrappedValue >= stopAt {
                timer.invalidate()
                
            }
            
        }
        
        return timer
    }
}


