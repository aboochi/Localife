//
//  SplashScreen.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/16/24.
//

import SwiftUI

struct SplashScreen: View {
    @State private var scale = 0.7
    @State var isActive: Bool = false
    var body: some View {
        
        ZStack{
            
            Color(hex: "#4169e1")
                .ignoresSafeArea()
            
            
            VStack {
                VStack {
                    LogoSplash(spacing: 20.0, color1: .white, color2: Color(hex: "#4169e1"))
                        .scaleEffect(0.6)
                    Text("LocaLife")
                        .foregroundColor(.white)
                        .font(.system(size: 60, weight: .heavy))
                    
                }.scaleEffect(scale)
                    .onAppear{
                        withAnimation(.easeIn(duration: 0.3)) {
                            self.scale = 0.9
                        }
                    }
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}


