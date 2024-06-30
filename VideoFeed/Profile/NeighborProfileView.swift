//
//  NeighborProfileView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/20/24.
//

import SwiftUI

struct NeighborProfileView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding var path: NavigationPath
    let accountOwner: DBUser


    let size: CGFloat = 35
    
    var body: some View {
        
        VStack{
           
            ScrollView{
                
                if let username = accountOwner.username{
                    
                    VStack{
                        Text("\(username)' neighbors")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.06))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                
                
                ForEach(viewModel.usersNeighbor, id: \.id){ user in
                    
                    if let username = user.username{
                        
                        requestCellView(user: user, username: username)
                    }
                    
                }
            }
            .refreshable {
                Task{
                    viewModel.usersNeighbor = []
                    viewModel.lastDocumentUserNeighbor = nil
                    try await viewModel.fetchNeighborUsers()
                }
            }
            
            
        }
        .onAppear{
            Task{
                try await viewModel.fetchNeighborUsers()
            }
        }
    }
    

  @ViewBuilder
 func requestCellView(user: DBUser, username: String) -> some View{
        
            HStack(alignment: .center){
                
                
                NavigationLink {
                    
                    ProfileView(viewModel: ProfileViewModel(user: user, currentUser: session.dbUser) , listingViewModel: ListingViewModel(user: user), path: .constant(NavigationPath()) , isPrimary: false)
                        .environmentObject(session)
                    
                } label: {
                    
                    
                    AvatarView(photoUrl: user.photoUrl, username: user.username, size: size)
                    Text(username)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                }

                
                
              
                
                
                Spacer()
                
                HStack{
                    
                    if user.id != session.dbUser.id{
                        
                        Button(action: {
                            Task{
                                
                                
                                if session.followingIds.contains(user.id){
                                    
                                    session.followerIds.removeAll(where: {$0 == user.id})
                                    session.userViewModel.dbUser?.followingNumber -= 1
                                    try await viewModel.unfollow(currentUser: session.dbUser, user: user)
                                    
                                } else if !session.requestIds.contains(user.id){
                                    
                                    if user.privacyLevel == PrivacyLevel.publicAccess.rawValue{
                                        
                                        session.followingIds.append(user.id)
                                        session.userViewModel.dbUser?.followingNumber += 1

                                        try await viewModel.follow(currentUser: session.dbUser, user: user)
                                        
                                    }else{
                                        session.requestIds.append(user.id)
                                        try await viewModel.request(currentUser: session.dbUser, user: user)
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                        }, label: {
                            
                            Text(session.followingIds.contains(user.id) ? "Following": session.requestIds.contains(user.id) ? "Requested" : (session.followerIds.contains(user.id) ? "Follow back" :"Follow") )
                            
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(10)
                        })
                        
                    }
                    
                }
                
            }
            .padding()
        }
    
    
}

