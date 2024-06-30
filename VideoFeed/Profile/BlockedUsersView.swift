//
//  BlockedUsersView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/21/24.
//


import SwiftUI

struct BlockedUsersView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    @EnvironmentObject var session: AuthenticationViewModel

    
    let size: CGFloat = 35
    
    var body: some View {
        
        VStack{
            ScrollView{
                ForEach(viewModel.blockedUsers, id: \.id){ user in
                    
                    if let username = user.username{
                        
                        requestCellView(user: user, username: username)
                    }
                    
                }
            }
            
            
        }
        .onAppear{
            Task{
                viewModel.blockedUsers = []
                try await viewModel.getBlockedUsers(blockedUserIds: session.dbUser.blockedIds)
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
                            
                            session.dbUser.blockedIds.removeAll { $0 == user.id }
                            viewModel.blockedUsers.removeAll(where: {$0.id == user.id})
                            try await viewModel.unBlockUser(targetUid: user.id)
                        }
                        
                    }, label: {
                        Text("Unblock")
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .background(.black)
                            .cornerRadius(10)
                    })
                    
                   
                    
                }
                
            }
            .padding()
        }
    
    
}


