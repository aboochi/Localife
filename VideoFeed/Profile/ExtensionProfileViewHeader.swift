//
//  ExtentionProfileViewHeader.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/8/24.
//

import SwiftUI

extension ProfileView{
    
    
    
    
    
     func handleUserAction() {
        Task {
            do {
                if session.dbUser.blockedIds.contains(viewModel.user.id) {
                    try await viewModel.unBlockUser()
                    session.userViewModel.dbUser?.blockedIds.removeAll(where: {$0 == viewModel.user.id})
                } else if viewModel.isFollowing {
                    try await viewModel.unfollow()
                    session.userViewModel.dbUser?.followingNumber -= 1
                } else if viewModel.user.privacyLevel == PrivacyLevel.publicAccess.rawValue {
                    try await viewModel.follow()
                    session.userViewModel.dbUser?.followingNumber += 1
                } else {
                    try await viewModel.request()
                }
            } catch {
                print("Error handling user action: \(error)")
            }
        }
    }
    
     func getButtonLabel() -> some View {
        if session.dbUser.blockedIds.contains(viewModel.user.id) {
            return stats(text: "Unblock", size: .infinity, color: .black)
        } else if viewModel.requested {
            return stats(text: "Requested", size: .infinity, color: .gray)
        } else {
            let buttonText = viewModel.isFollowing ? "Following" : (viewModel.FollowingYou ? "Follow Back" : "Follow")
            return stats(text: buttonText, size: .infinity, color: buttonText == "Following" ? .blue : .white)
        }
    }
    
    
    
    @ViewBuilder
    func stats(text: String, size: CGFloat = 150, color: Color ) -> some View {
        
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(color == .white ? .black : .white)
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
            .frame(maxWidth: size)
            .background(CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft, .topRight, .bottomRight]).fill(color))
            //.cornerRadius(7)
            //.padding(.bottom, 3)
        
            .overlay(
                
                Group{
                    if color == .white{
                        CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft, .topRight, .bottomRight])
                            .stroke(Color.black.opacity(1), lineWidth: 1)
                    }
                }
            )
    }
    
    
    
    @ViewBuilder
    func stats1(text: String, color: Color = .black) -> some View {
        
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(color)
        
        
    }
    var avatar: some View {
        Group {
            if viewModel.isMyOwnAccount {
                ZStack{
                    AvatarView(photoUrl: session.dbUser.photoUrl, username: session.dbUser.username, size: 100)
                    if let selectedImage = selectedImage{
                        
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(20)
                            .onAppear{
                               // HapticManager.shared.generateFeedback(of: .notification(type: .success))
                                
                            }
                        
                        
                    }
                }
                    .padding(3)
                    .background(.white)
                    .cornerRadius(22)
                    .overlay(
                        Button(action: {
                            presentImagePicker = true
                        }, label: {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white.opacity(1))
                                .font(.system(size: 12))
                                .padding(8)
                                .background(Color.blue.opacity(1))
                                .clipShape(Circle())
                                .padding(3)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: 15, y: 12)
                        }),
                        alignment: .bottomTrailing
                    )
            } else {
                AvatarView(photoUrl: viewModel.user.photoUrl, username: viewModel.user.username, size: 100)
                    .padding(3)
                    .background(.white)
                    .cornerRadius(22)
            }
        }
    }
    
    var profileBio: some View{
        
        VStack(alignment: .leading, spacing: 2){
            
            
            Text("@\(viewModel.user.username ?? "")")
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 10)
                .padding(.bottom, 8)
            
            if let firstName = viewModel.user.firstName, let lastName = viewModel.user.lastName, !firstName.isEmpty , !lastName.isEmpty {
                Text("\(firstName) \(lastName)")
                    .font(.system(size: 14, weight: .regular))
                   // .padding(.top, 5)
            } else if let firstName = viewModel.user.firstName , !firstName.isEmpty {
                Text("\(firstName)")
                    .font(.system(size: 14, weight: .regular))
                    //.padding(.top, 5)
            } else if let lastName = viewModel.user.lastName, !lastName.isEmpty {
                Text("\(lastName)")
                    .font(.system(size: 14, weight: .regular))
                    //.padding(.top, 5)
            }
            
            if let bio = viewModel.user.bio, !bio.isEmpty{
                
                Text(bio)
                    .font(.system(size: 14, weight: .regular))
                   // .padding(.top, 10)
            }

            Text("Member since: 2024")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.black)
            
            
            followInfo
                .padding(.top, 8)
            
           
            
        }
    }
    
    @ViewBuilder
    var followInfo: some View{
        
        HStack{
            
            
            if (viewModel.isMyOwnAccount || viewModel.isFollowing || viewModel.user.privacyLevel == PrivacyLevel.publicAccess.rawValue) && !viewModel.isBlocked{
                
                
              
                    
                    Button {
                        
                        let value = NavigationValuegeneral(type: .followers, user: viewModel.user)
                        path.append(value)
                        

                    } label: {
                        stats1(text: "\(viewModel.isMyOwnAccount ? session.dbUser.followerNumber : viewModel.user.followerNumber) Followers", color: .blue)

                    }
                    
                    Button {
                        
                        let value = NavigationValuegeneral(type: .following, user: viewModel.user)
                        path.append(value)


                    } label: {
                        stats1(text: "\(viewModel.isMyOwnAccount ? session.dbUser.followingNumber : viewModel.user.followingNumber) Following" , color: .blue)

                    }
    
                    
              

              
            
            }else{
                stats1(text: "\(viewModel.isMyOwnAccount ? session.dbUser.followerNumber : viewModel.user.followerNumber) Followers" , color: .blue)
                stats1(text: "\(viewModel.isMyOwnAccount ? session.dbUser.followingNumber : viewModel.user.followingNumber) Following" , color: .blue)

            }
    }
        
      
    }
    
    
    var badge: some View{
        
        VStack(spacing: 12){
            ZStack{
                Image(systemName: "shield")
                    .fontWeight(.ultraLight)
                    .foregroundColor(.gray.opacity(0.8))
                    .scaleEffect(2)
                
                Image(systemName: "shield")
                    .fontWeight(.ultraLight)
                    .foregroundColor(.gray.opacity(0.8))
                    .scaleEffect(1.7)
            }
            stats1(text: "Basic Account", color: .gray)

        }
        .padding(.horizontal, 10)
    }
    
    
    
    
    
    
    
    
    
}
