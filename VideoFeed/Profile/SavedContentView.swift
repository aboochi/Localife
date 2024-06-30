//
//  SavedContentView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/19/24.
//

import SwiftUI
import Kingfisher

struct SavedContentView: View {
    
    let spacing: CGFloat = 5
    let screenWidth = UIScreen.main.bounds.width

    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ProfileViewModel

    var body: some View {
        
        postGrid
    }
    
    
    
    @ViewBuilder
    var postGrid: some View{
        
        ScrollView(.vertical, showsIndicators: false){
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: 3), spacing: spacing) {
                ForEach(Array(viewModel.savedPosts.enumerated()), id: \.element.id) { index, post in
                    
                    
                    
                    if let thumbnail = post.thumbnailUrls.first, let firstUrl = post.urls.first{
                        
                         
                            
                            NavigationLink {
                                ProfilePostScrollView(appearedPostIndecis: [index-2, index-1, index, index+1, index+2], scrollTo: post.id , path: .constant(NavigationPath()), postType: .saved )
                                    .environmentObject(session)
                                    .environmentObject(viewModel)
                            } label: {
                                postCell(thumbnail: thumbnail, firstUrl: firstUrl, post: post)

                                
                            }
                            
                        }
                        
                        
                        
                    }
                }
            
        }
        .padding(spacing)
        .onAppear{
            
            Task{
                viewModel.savedPostIds = session.savedPostIds
                try await viewModel.fetchSavedPosts(fetchSteps: 5)
            }
        }
    }
    
    
    @ViewBuilder
    func postCell(thumbnail: String, firstUrl: String, post: Post) -> some View{
        
        KFImage(URL(string: thumbnail))
            .blur(radius: session.dbUser.hiddenPostIds.contains(post.id) ? 50 : 0)
            .resizable()
            .scaledToFill()
            .frame(width: (screenWidth - 4*spacing)/3, height: (screenWidth - 4*spacing)/3)
            .cornerRadius(10)
            .overlay(
                Group{
                    if firstUrl.contains("postVideos"){
                        Image(systemName: "video.fill")
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
                ,alignment: .bottomTrailing
            )
    }

    
    
}

