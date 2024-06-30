//
//  UsersToSendToView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/31/24.
//

import SwiftUI

struct UsersToSendToView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: SharePostViewModel
    let spacing: CGFloat = 15
    @State var selectedUser: DBUser?
    @Binding var sentUrl: String?

    var body: some View {
        
        VStack(spacing: 10){
            
            
            TextField("Search for people...", text: $viewModel.searchText)
                .padding(.horizontal)
                .background(Color.white)
                .frame( height: 35)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
      
            
            ScrollView(.vertical, showsIndicators: false){
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4), spacing: spacing) {
                    ForEach(viewModel.searchText.isEmpty ?  viewModel.users : viewModel.usersSearch , id: \.id){ user in
                        
                        if let username = user.username, let photoUrl = user.photoUrl{
                            VStack(spacing: 5){
                                
                                VStack{
                                    
                                    AvatarView(photoUrl: user.photoUrl, username: user.username, size: 70)
                                    
                                    
                                        .overlay(
                                            Group{
                                                if let selectedId = selectedUser?.id,  selectedId == user.id{
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor( .white )
                                                        .font(.system(size: 13, weight: .bold))
                                                        .padding(3)
                                                        .background(Circle().fill(.blue ))
                                                        .padding(2)
                                                        .background(Circle().fill( .white ))
                                                        .offset(x: 10, y: 7)
                                                }
                                            }
                                            ,alignment: .bottomTrailing
                                            
                                        )
                                    
                                    
                                    Text(username)
                                        .foregroundColor(.black)
                                        .font(.system(size: 12, weight: .semibold))
                                        .lineLimit(1)
                                }
                                .onTapGesture {
                                    if let selectedId = selectedUser?.id,  selectedId == user.id{
                                        
                                        selectedUser = nil
                                    }else{
                                        selectedUser = user
                                    }
                                }
                                
                                
                            }
                        }
                        
                    }
                }
            }
            
            
            Button {
                Task{
                    if let selectedUser = selectedUser{
                        try await viewModel.share( recipientUser: selectedUser)
                        sentUrl = viewModel.post?.thumbnailUrls.first

                        dismiss()
                    }
                }
            } label: {
                
                Text("Send")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue.opacity(selectedUser == nil ? 0.5 : 1))
                    .cornerRadius(20)
            }
          
            
            
            
            
        }
        .padding()
        
        .onChange(of: viewModel.searchText, { oldValue, newValue in
            viewModel.searchText = viewModel.searchText.lowercased()
        })
    }
}


