//
//  ListingCoverCell.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/11/24.
//

import SwiftUI
import FirebaseFirestore

struct ListingCoverCell: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    let listing: Listing
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let widthPortion: CGFloat = 0.9
    @State var showRestrictionOption: Bool = false
    var imageScale: CGFloat {
        return listing.category == ListingCategory.sale.rawValue ? 1 :  (listing.category == ListingCategory.shopping.rawValue ? 0.65 : 0.8)
    }
    var hasImages: Bool { 
        if let urls = listing.urls, urls.count > 0{
        return true
    }else{
        return false
    }
    }
    
    @Binding var path: NavigationPath
    
    @Binding var appearedPostIndecis: [Int]
    @Binding var playedPostIndex: Int
    let currentItemIndex: Int

    
    var body: some View {
        
        
        VStack{
        
            VStack{
                HStack(alignment: .center){
                    
                    
                    
                    
                        
                        ListingCellAvatarView(user: listing.user, time: listing.time, listing: listing)
                            .onTapGesture {
                                let value = NavigationValuegeneral(type: .profile, user: listing.user)
                                path.append(value)
                            }
                    

                    
                   

                    Spacer()
                    ListingPriceView(price: listing.price)
                        .blur(radius: session.dbUser.hiddenPostIds.contains(listing.id)  ?  40 : 0  )
                    ListingCategoryView(category: listing.category)
                        .blur(radius: session.dbUser.hiddenPostIds.contains(listing.id)  ?  40 : 0  )
                    actionOptions
                    
                }
                .padding()
                
                ListingTitleView(title: listing.title, widthPortion: widthPortion)
                    .blur(radius: session.dbUser.hiddenPostIds.contains(listing.id)  ?  40 : 0  )
                ListingTimeAndLocationView(category: listing.category, originPlaceName: listing.originPlaceName, originPlaceAddress: listing.originPlaceAddress, destinationPlaceName: listing.destinationPlaceName, destinationPlaceAdress: listing.destinationPlaceAdress, startTime: listing.desiredTime, endTime: listing.endTime)
                    .blur(radius: session.dbUser.hiddenPostIds.contains(listing.id)  ?  40 : 0  )
                
                    .padding(.horizontal)
                    
                
                if let urls = listing.urls, urls.count > 0{
                    MediaSlidePresenter(urls: urls, id: listing.id, aspectRatio: listing.aspectRatio, mediumCategory: .listing, appearedPostIndecis: $appearedPostIndecis, playedPostIndex: $playedPostIndex, currentItemIndex: currentItemIndex)
                        .scaleEffect(widthPortion * 0.9)
                        .frame(width: screenWidth * widthPortion * 0.9 , height: screenWidth * widthPortion * listing.aspectRatio * imageScale * 0.9)
                        .blur(radius: session.dbUser.hiddenPostIds.contains(listing.id)  ?  40 : 0  )
                        .clipped()
                }
                
                   
                Listingdescription(description: listing.description, hasImages: hasImages)
                    .blur(radius: session.dbUser.hiddenPostIds.contains(listing.id)  ?  40 : 0  )
                Spacer()
                
            }
            .frame(width: screenWidth * widthPortion)
            .frame(maxHeight: screenWidth * widthPortion * 1.4)
            .foregroundColor(.black)
            .background(Color(hex: "#eaf6f6"))
            .cornerRadius(25)
            .shadow(radius: 10)
            
            ListingCellBottomBar(viewModel: ListingCellviewModel(currentUser: session.dbUser, listing: listing), path: $path)
            .padding(.vertical, 5)
        }
        .frame(maxWidth: screenWidth * widthPortion)
       
        
        .overlay(
            hiddenOverlayMessage
            
        )
        
        
        .sheet(isPresented: $showRestrictionOption, content: {
            if let user = listing.user{
                RestrictionOptionsView(viewModel: ProfileViewModel(user: user, currentUser: session.dbUser), showOptions: $showRestrictionOption, contentCategory: .listing, contentId: listing.id, listing: listing, postCaption: nil)
                    .environmentObject(session)
                    .presentationDetents([session.dbUser.id == listing.ownerUid ?  .height(150) :   .height(270)])
            }
        })
       
    }
    
    @ViewBuilder
    var actionOptions: some View{
        
        
        
        Button {
            showRestrictionOption = true
        } label: {
            
            Image(systemName: "ellipsis")
                .imageScale(.medium)
                .rotationEffect(.degrees(90))
                .foregroundColor(.black)
                .padding(.vertical, 10)
        }

        
    }
    
    @ViewBuilder
    var hiddenOverlayMessage: some View{
        
        Group{
            if session.dbUser.hiddenPostIds.contains(listing.id){
                
                VStack{
                    
                    Image(systemName: "eye.slash")
                        .foregroundColor(.black)
                        .padding(.top)

                    Text("This content has been hidden as you requested. It won't appear in your feed anymore.")
                        .foregroundColor(.black)
                        .font(.system(size: 13, weight: .semibold))
                        .padding()
                        
                }
                .background(.white)
                .cornerRadius(20)
                .padding(25)
              
            }
        }
        
    }
    

    
   
}


