//
//  ProfileBodyView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/23/24.
//



import SwiftUI
import Kingfisher


extension ProfileView{
    
    @ViewBuilder
    var ProfileBodyView: some View {
        
        VStack{
            HStack{
                
                mostPopularPost
               
                
                Spacer()
                
                mostRecentListing
                

                
            }
            .padding()
            
           
            
            Picker("", selection: $selectedOption) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 5)
            
            if showProfile(){
                
                switch selectedOption{
                    
                case "Listings":
                    
                    listingGrid
                    
                default:
                    
                    postGrid
                    
                }
                
            }else{
                
                gridPlaceholder
            }
            
        }
     
    }
    
    
    
    
    @ViewBuilder
    var gridPlaceholder: some View{
        
        VStack(spacing: 25){
            
            Image(systemName:isBlocked() ? "moon.zzz.fill" : "lock.shield")
                .scaleEffect(3)
            
            Text(isBlocked() ? "No Activity Yet": "Private Account")
                .font(.system(size: 25, weight: .bold))
                .padding()
            
            
        }
            .foregroundColor(.gray)
            .frame(width: 300, height: 200)
            .background(.white)
            .cornerRadius(40)
            .shadow(radius: 10)
            .padding()
    }
    
    @ViewBuilder
    var listingGrid: some View{
        
        ScrollView(.vertical, showsIndicators: false){
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: 3), spacing: spacing) {
                ForEach(Array(listingViewModel.listingActiveOtherUser.enumerated()), id: \.element.id) { index, listing in
                    
                    
                   
                            
                            Button {
                                selectedListingId = listing.id
                                
                                let value = NavigationValuegeneral(type: .listingExplore, profileViewModel: viewModel, listingViewModel: listingViewModel, index: index, contentId: listing.id)
                                path.append(value)
                                
                                //path.append(NavigationValue(name: .listingExplore, contentId: listing.id, index: index))
                                homeIndex.feedViewIsAppear = false


                            } label: {
                                listingCell(listing: listing)
                            }


                       
                        
                        
                        
                    
                }
            }
        }
        .padding(spacing)
    }
    
    
    
    
    func showProfile() -> Bool{
        
        if viewModel.isMyOwnAccount{ return true }
        return !viewModel.user.blockedIds.contains(session.dbUser.id) && !session.dbUser.blockedIds.contains(viewModel.user.id) && !(viewModel.user.privacyLevel == PrivacyLevel.privateAccess.rawValue && !viewModel.isFollowing)
    }
    
    func isBlocked() -> Bool{
        return  viewModel.user.blockedIds.contains(session.dbUser.id) || session.dbUser.blockedIds.contains(viewModel.user.id)
    }
    
    
    @ViewBuilder
    func listingCell(listing: Listing) -> some View{
        
        ListingCoverCellExplore(listing: listing)
        
            .scaleEffect(((screenWidth - 4*spacing)/3)/(screenWidth*0.45))
           // .scaledToFill()
            .offset(x: 0, y: 0.115*((screenWidth - 4*spacing)/3))
            .frame(width: (screenWidth - 4*spacing)/3, height: (screenWidth - 4*spacing)/3)
            .cornerRadius(10)
    }
    
    @ViewBuilder
    func recentListingCell(listing: Listing) -> some View{
        
        ListingCoverCellExplore(listing: listing)
        
            .scaleEffect((screenWidth/2 - 20)/(screenWidth*0.45))
            .offset(x: 0, y: 0.115*(screenWidth/2 - 20))
            //.scaledToFit()
            .frame(width: screenWidth/2 - 20, height: screenWidth/2 - 20)
            .cornerRadius(20)
    }
    
    
    
    
    @ViewBuilder
    var postGrid: some View{
        
        ScrollView(.vertical, showsIndicators: false){
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: 3), spacing: spacing) {
                ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                    
                    
                    
                    if let thumbnail = post.thumbnailUrls.first, let firstUrl = post.urls.first{
                        
                           
                                postCell(thumbnail: thumbnail, firstUrl: firstUrl, post: post)
                                    .onTapGesture {
                                        
                                        contentId = post.id
                                        navigationIndex  = index
                                        
                                        let value = NavigationValuegeneral(type: .postExplore, profileViewModel: viewModel, index: index, contentId: post.id)
                                        path.append(value)
                                        
                                        
                                        //path.append(NavigationValue(name: .postExplore, contentId: post.id, index: index))
                                        homeIndex.feedViewIsAppear = false
                                    }
                                
                          
                        
                        .onAppear{
                            if let lastId = viewModel.posts.last?.id,    post.id == lastId{
                                
                                Task{
                                    try await viewModel.fetchPost()
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        .padding(spacing)
    }
    
    
    
    
    @ViewBuilder
    func popularPostCell(url: String, post: Post) -> some View{
        
        KFImage(URL(string: url))
            .blur(radius: session.dbUser.hiddenPostIds.contains(post.id) ? 50 : 0)
            .resizable()
            .scaledToFill()
            .frame(width: screenWidth/2 - 20, height: screenWidth/2 - 20)
            .cornerRadius(20)
      
            .overlay(
                Group{
                    if post.likeNumber > 0{
                        HStack(alignment: .center){
                            Image(systemName: "heart")
                            Text(" \(post.likeNumber)")
                                .font(.system(size: 20, weight: .semibold))
                            
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .bold))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 15)
                        .background( Capsule().fill(.gray.opacity(0.2)))
                        .padding(5)
                        
                    }
                }
                ,alignment: .bottomLeading
            )
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
        
            .overlay(
                Group{
                    if post.urls.count > 1{
                        Image(systemName: "photo.stack")
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
                ,alignment: .topTrailing
            )
        
        
    }
    
    
    
    @ViewBuilder
    var mostRecentListing: some View{
        
        Group{
            if let mostRecentListing = listingViewModel.listingActiveOtherUser.first, showProfile(){
                
               
                    
                    Button {
                       
                        let value = NavigationValuegeneral(type: .listingExplore, profileViewModel: viewModel, listingViewModel: listingViewModel, index: 0, contentId: mostRecentListing.id)
                        path.append(value)
                        
                        
                        //path.append(NavigationValue(name: .popularListing, contentId: mostRecentListing.id, index: 0))
                        homeIndex.feedViewIsAppear = false


                    } label: {
                        recentListingCell(listing: mostRecentListing)

                    }

               
            }else{
                ListingPlaceholder()
            }
        }
    }
    
    
    
    @ViewBuilder
    var mostPopularPost: some View{
        
        Group{
            
            if let post = viewModel.mostPopularpost, let url = post.thumbnailUrls.first, showProfile(){
                let index = viewModel.popularPostIndex
                
                
                    
                    Button {
                        contentId = post.id
                        navigationIndex  = index
                        
                        let value = NavigationValuegeneral(type: .postExplore, profileViewModel: viewModel, index: index, contentId: post.id)
                        path.append(value)
                        
                       // path.append(NavigationValue(name: .popularPost, contentId: post.id, index: index))
                        homeIndex.feedViewIsAppear = false


                    } label: {
                        popularPostCell(url: url, post: post)

                    }

                    
               
                
            }else{
                
                PostPlaceholder()
                
            }
        }
    }
    
    
}

