//
//  StoryView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/7/24.
//

import SwiftUI
import Kingfisher

struct StoryView: View {
    @EnvironmentObject var viewModel :  StoryViewModel
    @Binding var showStorySlide : Bool
    @Binding var storyUserIndex: Int
    @Binding  var storyAnchorPoint: UnitPoint 
    
    var body: some View {
        
        ZStack{
            VStack {
                //Spacer().frame(height: 16) // Add margin above the ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        
                        MyStory() // Add MyStory as the first element
                        
                        
                        ForEach(Array(viewModel.stories.enumerated()), id: \.offset){ index, story in
                            
                            GeometryReader { geometry in
                                
                             
                                StoryPreviewCellView(story: story)
                                    .onTapGesture {
                                        
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            storyAnchorPoint = UnitPoint(x: geometry.frame(in: .global).midX / UIScreen.main.bounds.width,
                                                                    y: geometry.frame(in: .global).midY / UIScreen.main.bounds.height)
                                            showStorySlide = true
                                        }
                                        
                                        storyUserIndex = index
                                        print("userindex: \(storyUserIndex)")
                                       
                                    }
                            }
                            .frame(width: 84, height: 84)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    
                }
                
              
            }
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.2)) // Gray transparent overlay (applied to the VStack)
          
            

            
            
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}


struct MyStory: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 84, height: 84)
                .foregroundColor(Color.black) // Black rectangle
                .clipShape(Rectangle()) // Use Rectangle instead of Circle
                .border(Color.white, width: 3) // White border with thickness 3
                .shadow(color: Color.gray.opacity(0.5), radius: 2, x: 4, y: 4) // Add a shadow
            
            
            
            Rectangle()
                .frame(width: 84, height: 3) // Horizontal frame thickness of 3
                .foregroundColor(.white) // White frame for horizontal line
                .offset(y: 0) // Center the horizontal line
            
            Rectangle()
                .frame(width: 3, height: 84) // Vertical frame thickness of 3
                .foregroundColor(.white) // White frame for vertical line
                .offset(x: 0) // Center the vertical line
            
            Circle()
                .frame(width: 20, height: 20) // Blue circle with a diameter of 40
                .foregroundColor(Color.blue)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2) // White border with thickness 2
                )
                .offset(x: 20, y: 20) // Position the circle in the bottom left subrectangle
            
            Image(systemName: "moon.fill") // System icon for the moon
                .resizable()
                .frame(width: 20, height: 20) // Adjust size as needed
                .foregroundColor(.white) // Set moon icon color
                .offset(x: -21, y: -21) // Position the moon icon in the upper left subrectangle
            
            Rectangle()
                .frame(width: 13, height: 2) // White horizontal line in the cross
                .foregroundColor(.white)
                .offset(x: 20, y: 20)
            
            Rectangle()
                .frame(width: 2, height: 13) // White vertical line in the cross
                .foregroundColor(.white)
                .offset(x: 20, y: 20)
        }
    }
}

