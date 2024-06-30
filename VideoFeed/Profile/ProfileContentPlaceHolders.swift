//
//  ProfileContentPlaceHolders.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/9/24.
//

import SwiftUI

struct PostPlaceholder: View {
    
    let screenWidth = UIScreen.main.bounds.width
    var body: some View {
        
        ZStack{
            Image("postPlaceholder")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: screenWidth/2 - 20, height: screenWidth/2 - 20)
                .cornerRadius(20)
            
            
            Text("No Post Yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black.opacity(0.7))
                .shadow(radius: 10)
                .padding()
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
                .offset(y: (screenWidth/2 - 20)/2 - 20)
        }
    }
}

struct ListingPlaceholder: View{
    let screenWidth = UIScreen.main.bounds.width

    var body: some View{
        
        ZStack{
            Image("listingPlaceholder")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: screenWidth/2 - 20, height: screenWidth/2 - 20)
                .cornerRadius(20)
            
            
            Text("No Listing Yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black.opacity(0.7))
                .shadow(radius: 10)
                .padding(.horizontal, 25)
                .padding(.vertical, 5)
                .background(.white.opacity(1))
                .clipShape(Capsule())
                .offset(y: (screenWidth/2 - 20)/2 - 20)
            
        }

    }
}


