//
//  ListingCoverCellExplore.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/13/24.
//



import SwiftUI
import FirebaseFirestore
import Kingfisher

struct ListingCoverCellExplore: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    let listing: Listing
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    


    
    var body: some View {
        
        
        VStack{
            
            VStack(alignment: .leading){
                
                VStack{
                    if let thumbnail = listing.thumbnailUrls?.first, let url = listing.urls?.first, listing.category != ListingCategory.shopping.rawValue || listing.category != ListingCategory.other.rawValue{
                        coverImage(thumbnail: thumbnail, url: url)
                        
                    } else {
                        
                        VStack(alignment: .leading){
                            
                            timeAndLocation
                            if listing.destinationLocation == nil{
                                description
                            }
                            Spacer()
                            
                        }
                        .blur(radius: session.dbUser.hiddenPostIds.contains(listing.id) ? 70 : 0)
                        .modifier(ListingBackground())
                        .overlay(
                            headerOverlayTop
                            , alignment: .top
                        )
                    }
                }
                .frame(width: screenWidth * 0.45, height: screenWidth * 0.45)
                
                
                titleAndtime
                
                Spacer()
                
            }
            .frame(width: screenWidth * 0.45, height: screenWidth * 0.50)
            
           
        }
        .frame(width: screenWidth * 0.45, height: screenWidth * 0.50)
    }
    
}


//MARK - EXTENSION
extension ListingCoverCellExplore{
    
  
    
    @ViewBuilder
    var timeAndLocation: some View{
        
        
        ListingTimeAndLocationViewSmall(category: listing.category, originPlaceName: listing.originPlaceName, originPlaceAddress: listing.originPlaceAddress, destinationPlaceName: listing.destinationPlaceName, destinationPlaceAdress: listing.destinationPlaceAdress, startTime: listing.desiredTime, endTime: listing.endTime)
            .padding(.top, 32)
        
    }
    
    @ViewBuilder
    var titleAndtime: some View{
        
        
        Text(listing.title)
            .padding(0)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.black)

        
        
        Text(TimeFormatter.shared.timeAgoFormatter(time: listing.time))
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .padding(.top, 0)
    }
    
    
    @ViewBuilder
    var description: some View{
        
        if let description = listing.description, description.count > 0{
            Text(description)
                .foregroundColor(.black)
                .font(.system(size: 13, weight: .regular))
                .lineLimit(5)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 10)
            
        }
    }
    
    
    @ViewBuilder
    func coverImage(thumbnail: String, url: String) -> some View{
        KFImage(URL(string: thumbnail))
            .blur(radius: session.dbUser.hiddenPostIds.contains(listing.id) ? 70 : 0)
            .resizable()
            .scaledToFill()
            .frame(width: screenWidth * 0.45, height: screenWidth * 0.45 )
            .cornerRadius(12)
            .overlay(
                headerOverlayTop
                , alignment: .top
            )
            .overlay(
                headerOverlayBottom
                , alignment: .bottom
            )
            .overlay(
                Group{
                    if url.contains("Videos"){
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                }
                ,alignment: .center
            )
        
        
    }
    
   
    @ViewBuilder
    var headerOverlayBottom: some View{
        
        if listing.category == ListingCategory.event.rawValue, let locationName = listing.originPlaceName{
            
            Text(locationName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(5)
                .background(Capsule().fill(.white.opacity(0.6)))
                .shadow(radius: 5)
                .padding(5)
            
        }
    }
    
    
    
    
    
    @ViewBuilder
    var headerOverlayTop: some View{
        
        HStack(alignment: .center){
            
            if listing.category != ListingCategory.ride.rawValue{
                if let price = listing.price, price > 0{
                    Text("$\(String(format: "%.0f", price))")
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .bold))
                        .background(Color.yellow.opacity(0.7))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            } else {
                if let origin = listing.originPlaceName, let destination = listing.destinationPlaceName{
                    if origin.contains("Airport") || destination.contains("Airport"){
                        Image(systemName: "airplane")
                            .foregroundColor(.black)
                            .padding(.horizontal, 5)


                            
                    } else{
                        Image(systemName: "car.side.fill")
                            .foregroundColor(.black)
                            .scaleEffect(x: -1, y: 1)
                            .padding(.horizontal, 5)

                            
                        
                        
                    }
                }
            }
            
            if listing.category == ListingCategory.other.rawValue && listing.price == 0{
                if let photoUrl = listing.user?.photoUrl{
                    AvatarView(photoUrl: photoUrl, username: listing.user?.username, size: 30)
                }else if let username = listing.user?.username{
                    Text(username)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .foregroundColor(.black)
                        .font(.system(size: 13, weight: .semibold))
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal, 5)

                }
            }
            
            Spacer()
            
            Text(listing.category)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .background(Color(hex: CategoryColorProvider.getColor(for: listing.category)).opacity(0.7))
                .cornerRadius(10)

        }
        .padding(.horizontal, 5)
        .padding(.vertical, 5)

    }
    
    
    
    
    
    
}

struct ListingBackground: ViewModifier{
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    func body(content: Content) -> some View {
        content
            .frame(width: screenWidth * 0.45, height: screenWidth * 0.45 )
            .background(
                
                RadialGradient(
                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)), Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))]),
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: UIScreen.main.bounds.height * 0.45)
                
            )
            .cornerRadius(12)
    }
    
    
    
    
}


