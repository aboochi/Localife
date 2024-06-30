//
//  StoryPagingView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/7/24.
//

import SwiftUI

struct StoryPagingView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: StoryViewModel
    @Binding var currentUserIndex: Int
    let screenWidth =  UIScreen.main.bounds.width
    @State var isScrolling: Bool = true
    @Binding var showStorySlide: Bool
    @State var backgroundColor: Color = .black
    @State var offset: CGFloat = 0

    
    
    var body: some View {
        ScrollViewReader{ proxy in
            ScrollView(.horizontal, showsIndicators: false){
                HStack(alignment: .center, spacing: 0){
                    ForEach(Array(viewModel.stories.enumerated()), id: \.offset){ index, story in
                        
                        
                        // GeometryReader{ geo in
                        ZStack{
                            if index == currentUserIndex || index == currentUserIndex + 1 || index == currentUserIndex - 1{
                                if let user = story.user{
                                    VStack{
                                        Spacer()
                                        StorySlideView( viewModel: StoryPerUserViewModel(user: user), currentUserIndex: $currentUserIndex, userIndex: index, isScrolling: $isScrolling)
                                            .frame(width: screenWidth, height: screenWidth / story.aspectRatio)
                                          
                                           
                                        Spacer()
                                    }
                                    .background(backgroundColor)
                                    .overlay(
                                        Button(action: {
                                            backgroundColor = .clear
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                showStorySlide = false
                                            }
                                        }, label: {
                                            Image(systemName: "xmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 24, weight: .light))
                                                .padding(.top, 120)
                                                .padding(.horizontal)
                                        })
                                        , alignment: .topTrailing)
                                    
                                        .scrollTransition(axis: .horizontal) { content, phase in
                                            content
                                                .scaleEffect(y: phase.isIdentity ? 1.0 : 0.70)
                                                .rotation3DEffect(.degrees(phase.value * 45), axis: (x: 0, y: 1, z: 0))
                                            
                                        }
                                    
                                        .id(index)
                                }

                            }
                        }
                        
                        .background(
                            
                            GeometryReader { geo in
                                Color.clear
                                
                                    .onChange(of: geo.frame(in: .global)) { oldValue, newValue in
                                        
                                        
                                        
                                        
                                        if newValue.midX < 0  && isScrolling{
                                            if currentUserIndex == index{
                                                
                                                if  currentUserIndex < viewModel.stories.count - 1{
                                                    currentUserIndex+=1
                                                }
                                                
                                                
                                                
                                                print("index incremented \(currentUserIndex)")
                                                
                                            }
                                            
                                        } else if newValue.midX > geo.size.width && isScrolling {
                                            if currentUserIndex == index  {
                                                
                                                if currentUserIndex > 0 {
                                                    currentUserIndex-=1
                                                }
                                                
                                                // print("index decremented \(currentUserIndex)")
                                                
                                            }
                                        }
                                    }
                            }
                        )
                    }
                    
                    .onChange(of: currentUserIndex) { oldValue, newValue in
                        
                        print("selected index inside on change: \(currentUserIndex)")
                        if currentUserIndex >= 0 && currentUserIndex < viewModel.stories.count {
                            
                                proxy.scrollTo(currentUserIndex)
                            
                        }
                    }
                    .onAppear{
                        print("selected index on appear: \(currentUserIndex)")
                        proxy.scrollTo(currentUserIndex)
                    }
                    
                }
            }
            .scrollTargetBehavior(.paging)
            
        }
       
    }
}

