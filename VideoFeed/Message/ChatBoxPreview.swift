//
//  ChatBoxPreview.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/20/24.
//

import SwiftUI

struct ChatBoxPreview: View {
    @StateObject var viewModel : ChatViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    
    var body: some View {
        
        
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.messages.reversed().enumerated()), id: \.element.id) { index, message in
                    VStack{
                        
                        
                        let ownAccount = message.ownerId == session.dbUser.id
                        //displayDate(index: index, message: message)
                        //MessageCellView(message: message, otherUser: viewModel.otherUser, scrollToId: $scrollToId)
                        //    .environmentObject(viewModel)
                        
                    }
                }
            }
        }
    }
}


