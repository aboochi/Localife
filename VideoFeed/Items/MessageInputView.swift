//
//  SwiftUIView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//

import SwiftUI

struct MessageInputView: View {
    
    @Binding var message: String
    
    var action: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            TextField("Message...", text: $message)
                .padding(.horizontal)
                .frame(height: 45)
                .background(Color.primary.opacity(0.06))
                .clipShape(Capsule())
            
            if !message.isEmpty {
                Button(action: action) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 45, height: 45)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
        }.padding()
    }
}
