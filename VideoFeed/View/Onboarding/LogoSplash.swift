//
//  LogoSplash.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/9/24.
//



// topLeft    topRight  bottomLeft    bottomRight
import SwiftUI

struct LogoSplash: View {
    
    let spacing: CGFloat
    let color1: Color
    let color2: Color //Color(hex: "#663196")
    var body: some View {
        
        VStack(spacing: spacing){
            HStack(spacing: spacing){
                shape
                    .clipShape(CustomCorners(radius: 50, corners: [ .bottomLeft, .topRight, .topLeft,  .bottomLeft]))
                
                    .foregroundColor(color1)
                
                    .overlay(
                        Circle()
                            .foregroundColor( color2)
                            .frame(width: 50)
                        
                        
                    )
                shape
                    .clipShape(CustomCorners(radius: 50, corners: [ .topLeft]))
                
                    .foregroundColor(color1)
            }
            
            HStack(spacing: spacing){
                shape
                    .clipShape(CustomCorners(radius: 50, corners: [ .topLeft, .bottomRight]))
                
                    .foregroundColor(color1)
                shape
                    .clipShape(CustomCorners(radius: 50, corners: []))
                    .foregroundColor(color1)
                
                
            }
            
        }
        .frame(width: 225, height: 225)
        }
      
       
       
    
    
    
    var shape: some View{
        
        Rectangle()
            .frame(width: 100, height: 100)
           
           
    }
    
}


