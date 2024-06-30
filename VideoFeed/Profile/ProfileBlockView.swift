//
//  ProfileBlockView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/8/24.
//

import SwiftUI

struct ProfileBlockView: View {
    
    
    @EnvironmentObject var viewModel: ProfileViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding  var showOptions: Bool
    
    var body: some View {
        
        VStack(spacing: 20) {
            if let photoUrl = viewModel.user.photoUrl {
                AvatarView(photoUrl: photoUrl, username: viewModel.user.username, size: 60)
            }
            
                if let username = viewModel.user.username {
                    Group {
                        Text("Blocking ")
                        +
                        Text(username)
                            .font(.system(size: 16, weight: .bold))
                        +
                        Text("?")
                    }
                    .multilineTextAlignment(.center)  // Center align text

                    Group {
                        Text("When you block an account, any communication between you and the account will be blocked until you unblock the account.")
                        
                        +
                        Text("We will not notify ")
                        +
                        Text(username)
                            .font(.system(size: 16, weight: .bold))
                        +
                        Text(" that you blocked them.")
                     
                    }
                        .foregroundColor(.gray)
                        .font(.system(size: 16, weight: .regular))
                        .multilineTextAlignment(.center)  // Center align text
                        .padding(10)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(15)

                }
           

            
            VStack{
                Button {
                    
                    Task{
                        try await viewModel.blockUser()
                        session.userViewModel.dbUser?.blockedIds.append(viewModel.user.id)
                        showOptions = false
                    }
                    
                    
                
                } label: {
                    Text("Block")
                        .padding()
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(.blue))
                }
                
                Button {
                    
                    showOptions = false
                
                } label: {
                    Text("Never mind")
                        .padding()
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .regular))
                        .frame(maxWidth: .infinity)
                        
                }

            }
        }
        .padding()
    }
}


