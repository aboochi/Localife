//
//  CircularProgressView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/17/24.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: CGFloat
    var size: CGFloat
    var color: Color = .white
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 20)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(color.opacity(0.7), lineWidth: 20)
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
                .animation(.easeInOut)
            
//            Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
//                .font(.title)
//                .fontWeight(.bold)
//                .foregroundColor(color.opacity(0.5))
        }
        .padding()
    }
}


