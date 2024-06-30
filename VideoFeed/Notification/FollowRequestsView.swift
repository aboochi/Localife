//
//  FollowRequestsView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/19/24.
//

import SwiftUI

struct FollowRequestsView: View {
    
    @EnvironmentObject var viewModel: NotificationViewModel
    @EnvironmentObject var session: AuthenticationViewModel

    
    let size: CGFloat = 35
    
    var body: some View {
        
        VStack{
            ScrollView{
                ForEach(viewModel.requestingUsers, id: \.id){ user in
                    
                    if let username = user.username{
                        
                        requestCellView(user: user, username: username)
                    }
                    
                }
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
                    
                    Button(action: {
                        Task{
                            try await viewModel.acceptRequest(user: user)
                        }
                        
                    }, label: {
                        Text("Accept")
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(10)
                    })
                    
                    
                    Button(action: {
                        Task{
                            try await viewModel.declineRequest(userId: user.id)

                        }
                        
                    }, label: {
                        Text("Decline")
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .background(.gray)
                            .cornerRadius(10)
                    })
                    
                    
                    
                    
                }
                
            }
            .padding()
        }
    
    
}


