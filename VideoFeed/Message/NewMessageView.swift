//
//  NewMessageView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//


import SwiftUI

struct NewMessageView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: MessageViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var chatClosed: String?
    @State var closeNewMessage: Bool = false
    @State var presentSearchable: Bool = false
    @Binding var path: NavigationPath

    var body: some View {
        
        NavigationStack{
            VStack{
                
                
                ScrollView(showsIndicators: false){
                    VStack{
                        
                        if presentSearchable {
                            forEachLoop(users: viewModel.usersSearch)
                        }else {
                           forEachLoop(users: viewModel.usersNeighbor)
                           // forEachLoop(users: viewModel.usersTime)

                        }
                      
                    }
                }
              
            }
            .searchable(text: $viewModel.searchString, isPresented: $presentSearchable)
            

            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
     
            .onChange(of: viewModel.searchString, { oldValue, newValue in
                viewModel.searchString = viewModel.searchString.lowercased()
            })
            .onAppear{
                Task{
                    do{
                        try await viewModel.fetchNeighborUsers()
                        try await viewModel.fetchUsersByTime()

                    }
                }
            }
        }
        .onChange(of: closeNewMessage) { oldValue, newValue in
            if newValue{
                dismiss()
            }
        }
    }
    
    
    @ViewBuilder
    func forEachLoop(users: [DBUser]) -> some View{
        
        ForEach(users, id: \.id){ user in
            
            
           
                AvatarAndUsername(photoUrl: user.photoUrl, username: user.username)
                    .onAppear() {
                        
                        if viewModel.chatBoxViewModels[user.id] == nil {
                            viewModel.chatBoxViewModels[user.id] = ChatViewModel(currentUser: session.dbUser, otherUser: user)
                            
                        }
                    }
                    .onTapGesture {
                        
                        if let chatViewModel = viewModel.chatBoxViewModels[user.id] {
                            let value = NavigationValuegeneral(type: .chatbox,  chatViewModel: chatViewModel, userId: user.id)
                            path.append(value)
                        }
                    }
            

     

        }
    }
    
    
    
   
}



struct AvatarAndUsername: View{
    
    let photoUrl: String?
    let username: String?
    
    var body: some View{
        
        HStack(alignment: .center){
            AvatarView(photoUrl: photoUrl, username: username)
            Text(username ?? "Unknown")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                Spacer()
            

        }
        .padding(10)
        
    }
}

