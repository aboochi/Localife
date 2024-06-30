//
//  StoryPreviewCellView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/29/24.
//

import SwiftUI
import Kingfisher

struct StoryPreviewCellView: View {
    let story: Story
    var body: some View {
        
        ZStack{
            Rectangle()
                .frame(width: 84, height: 84) // Match the image size
                .foregroundColor(Color.yellow.opacity(0.7)) // Yellow transparent overlay
                .clipShape(Rectangle()) // Use Rectangle instead of Circle
                .shadow(color: Color.gray.opacity(0.5), radius: 2, x: 4, y: 4) // Add a shadow
            
            
            
            KFImage(URL(string: story.imageUrl)!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 84, height: 84) // Adjust size to fit inside the rectangle
                .clipShape(Rectangle()) // Use Rectangle instead of Circle
                .border(Color.white, width: 3) // White border with thickness 3
                .shadow(color: Color.gray.opacity(0.5), radius: 2, x: 4, y: 4) // Add a shadow
            //.blur(radius: 2) // Add a blur effect
            
            
            
            
            Rectangle()
                .frame(width: 78, height: 78) // Match the image size
                .foregroundColor(Color.black.opacity(0.45)) // Yellow transparent overlay
                .clipShape(Rectangle()) // Use Rectangle instead of Circle
            
            Rectangle()
                .frame(width: 79, height: 3) // Horizontal frame thickness of 4
                .foregroundColor(.white) // White frame for horizontal line
                .offset(y: 0) // Center the horizontal line
                .shadow(color: Color.gray.opacity(0.5), radius: 2, x: 2, y: 0) // Add a shadow
            
            
            Rectangle()
                .frame(width: 3, height: 79) // Vertical frame thickness of 4
                .foregroundColor(.white) // White frame for vertical line
                .offset(x: 0) // Center the vertical line
                .shadow(color: Color.gray.opacity(0.5), radius: 2, x: 2, y: 0) // Add a shadow
            
        }
    }
}

