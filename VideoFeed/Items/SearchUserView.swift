//
//  SearchUserView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/2/24.
//

import SwiftUI

struct SearchUserView: View {
    
    @EnvironmentObject var viewModel: UserSearchViewModel
    var body: some View {
       
        VStack{
            TextField("Search for people...", text: $viewModel.searchString)
                .padding()
            ScrollView(showsIndicators: false){
                VStack{
                    ForEach(viewModel.usersSearch, id: \.id){ user in
                        
                        HStack{
                            AvatarView(photoUrl: user.photoUrl, username: user.username, size: 40)
                            if let username = user.username{
                                Text(username)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onChange(of: viewModel.searchString) { oldValue, newValue in
            viewModel.searchString = viewModel.searchString.lowercased()
        }
    }
}

#Preview {
    SearchUserView()
}
