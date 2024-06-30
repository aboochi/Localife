//
//  ProfileViewNavigationExtension.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/13/24.
//

import SwiftUI


extension ProfileView{
    
    @ViewBuilder
    func handleNavigation(value: NavigationValue) -> some View{
        
        switch value.name{
        case .setting:
            
            SettingView1()
                .environmentObject(session)
                .environmentObject(viewModel)
    
            
        case .followers:
            
          EmptyView()
               
            
        case .following:
            
            
            EmptyView()
            
        case .neighbors:
            
            NeighborProfileView(path: $path, accountOwner: viewModel.user)
                .environmentObject(session)
                .environmentObject(viewModel)
            
        case .editProfile:
            
            ProfileEditView()
                 .environmentObject(session)
                 .environmentObject(viewModel)
            
        case .postExplore:
            
            ProfilePostScrollView(appearedPostIndecis: [value.index-2, value.index-1, value.index, value.index+1, value.index+2], scrollTo: value.contentId , path: $path, postType: .profile )
                .environmentObject(session)
                .environmentObject(viewModel)
            
            
        case .popularPost:
            
            ProfilePostScrollView(appearedPostIndecis: [value.index-2, value.index-1, value.index, value.index+1, value.index+2], scrollTo: value.contentId , path: $path, postType: .profile )
                .environmentObject(session)
                .environmentObject(viewModel)
            
        case .listingExplore:
            
            ListingScrollWrapper(scrollTo: value.contentId, userId: viewModel.user.id, listingType: .otherUser, path: $path) { scrollTo, userId, listingType, path in
                
                ListingScrollViewGeneral(scrollTo: scrollTo, userId: userId, listingType: listingType, path: path)

            }
            .environmentObject(listingViewModel)

            
            

        case .popularListing:
            if let mostRecentListing = viewModel.listings.first{
                
                
                ListingScrollWrapper(scrollTo: value.contentId, userId: viewModel.user.id, listingType: .otherUser, path: $path) { scrollTo, userId, listingType, path in
                    
                    ListingScrollViewGeneral(scrollTo: scrollTo, userId: userId, listingType: listingType, path: path)

                }
                .environmentObject(listingViewModel)
                
                
                
                
            }

        case .none:
            EmptyView()

        }
    }
}
