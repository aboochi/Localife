//
//  MessageReactionBar.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/18/24.
//

import SwiftUI

struct MessageReactionBar: View {
    
    @EnvironmentObject var viewModel: ChatViewModel
    private let emojis: [String] = ["😍", "😂", "❤️", "🎉", "😘", "😎"]
    @State private var emojisDict: [Int : Bool] = [0: false, 1: false, 2: false, 3: false, 4: false, 5: false]
    @State private var showReactionsBackground = false
    @State var selectedEmoji: String?
    @State private var showLike = false
    @State private var showThumbsUp = false
    @State private var thumbsUpRotation: Double = -45
    @State private var showThumbsDown = false
    @State private var thumbsDownRotation: Double = -45
    @State private var showLol = false
    @State private var showWutReaction = false
    @State private var isContextMenuVisible = false
    let ownAccount: Bool
    let message: Message
    @Binding var showContextMenu: Bool

    
    var body: some View {
       
            
            ZStack{
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                    .frame(width: 300, height: 45)
                    .scaleEffect(showReactionsBackground ? 1 : 0, anchor: ownAccount  ? .bottomTrailing : .bottomLeading)
                    .animation(
                        .interpolatingSpring(stiffness: 170, damping: 10).delay(0.05),
                        value: showReactionsBackground
                    )
                
                HStack {
                    ForEach(Array(emojis.enumerated()), id: \.element) { index, emoji in
                        
                        
                        ZStack{
                            Text(emojis[index])
                            
                                .font(.largeTitle)
                            
                                .background( Color.clear.opacity(0.3) ) // Adjust opacity as needed
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .shadow(color : Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .scaleEffect(emojisDict[index] ?? false ? 1 : 0)
                        .rotationEffect(.degrees(thumbsUpRotation))
                        
                        .onTapGesture {
                            showContextMenu = false
                            Task{
                                try await viewModel.react(message: message, emoji: emoji)
                            }
                            
                        }
                    }
                }
                .font(.largeTitle)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                
                .cornerRadius(30)
               
                
                
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, ownAccount ? 10 : 40 )
        
            .onAppear(){
                
                showReactionsBackground = true
                
                for index in  0..<6 {
                    let value = ownAccount ? 5 - index : index
                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 5).delay(0.1*(Double(value)+1))) {
                        emojisDict[index] = true
                        thumbsUpRotation =  0

                    }
                }
            }
            

        
        
        }
        
        
    
}


