//
//  Logo.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/8/24.
//

// topLeft    topRight  bottomLeft    bottomRight
import SwiftUI

struct Logo: View {
    
    let spacing = 27.0
    var body: some View {
        
        ZStack{
            
            Color.white.opacity(0.4)
            
            VStack(spacing: spacing){
                
                
                
                HStack(spacing: spacing){
                    shape
                        .clipShape(CustomCorners(radius: 50, corners: [ .bottomLeft, .topRight, .topLeft]))
                       // .foregroundColor(Color(hex: "#fcf7cf"))
                        .foregroundColor(.white)

                        .overlay(
                            Circle()
                                .foregroundColor( Color(hex: "#4169e1"))
                                .frame(width: 50)
                            // .foregroundColor(Color(hex: "#f6bf26"))
                            
                        )
                    shape
                        .clipShape(CustomCorners(radius: 50, corners: [ .topLeft]))
                        //.foregroundColor(Color(hex: "#f6bf26"))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: spacing){
                    shape
                        .clipShape(CustomCorners(radius: 50, corners: [ .topLeft, .bottomRight]))
                        //.foregroundColor(Color(hex: "#ead669"))
                        .foregroundColor(.white)
                    shape
                        .clipShape(CustomCorners(radius: 50, corners: []))
                        .foregroundColor(.white)
//                        .overlay(
//                            Image(systemName: "star.fill")
//                                .foregroundColor(Color(hex: "#fcf7cf"))
//                                .scaleEffect(2)
//                            
//                        )
                    
                }
                
                
                
            }
            .padding(75)
            .background(Color(hex: "#4169e1"))  // #00778b    //#cc6600    #663196  #4169e1  #548ca1
            //.cornerRadius(70)
        }
       
       
    }
    
    
    var shape: some View{
        
        Rectangle()
            .frame(width: 100, height: 100)
           
           
    }
    
}

#Preview {
    Logo()
}
