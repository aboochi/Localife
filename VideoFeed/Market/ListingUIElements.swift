//
//  ListingUIElements.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//

import SwiftUI
import FirebaseFirestore

struct ListingCellAvatarView: View {
    
    let user: DBUser?
    let time: Timestamp
    let listing: Listing?
    
    var body: some View {
        
        HStack(alignment: .top){
            if let user = user{
                
                AvatarView(photoUrl: user.photoUrl, username: user.username)
                let username = user.username
                VStack(alignment: .leading){
                    Text(username ?? "unknown user")
                        .font(.system(size: 14, weight: .semibold))
                    
                    HStack(spacing: 5){
                        Text(TimeFormatter.shared.timeAgoFormatter(time: time))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        if let listing = listing, listing.isEdited{
                            
                            Text("Edited")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        
     
    }
}


struct ListingPriceView: View{
    
    let price: Double?
    
    var body: some View{
        
        if let price = price, price > 0{
            Text("$\(formattedPrice(price))")
                .padding(10)
                .font(.system(size: 14, weight: .bold))
                .background(Color.yellow)
                .cornerRadius(5)
                .shadow(radius: 5)
        }
    }
    
    
    private func formattedPrice(_ price: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0 // No decimal points for whole dollars
        return numberFormatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
}

struct ListingCategoryView: View{
    
    let category: String
    
    var body: some View{
        
        Text(category)
            .padding(10)
            .font(.system(size: 14, weight: .bold))
            .background(Color(hex: CategoryColorProvider.getColor(for: category)))
            .cornerRadius(5)
            .shadow(radius: 5)
    }
}

struct ListingTitleView: View{
    
    let title: String
    let widthPortion: CGFloat
    let screenWidth = UIScreen.main.bounds.width
    var body: some View{
        
        Text(title)
            .padding(10)
            .padding(.horizontal, 3)
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: screenWidth * widthPortion )
            .background(Color.white)
            .cornerRadius(5)
            .shadow(radius: 5)
            .padding(.horizontal)
    }
}


struct ListingTimeAndLocationView: View{
    
    let category: String
    let originPlaceName: String?
    let originPlaceAddress: String?
    let destinationPlaceName: String?
    let destinationPlaceAdress: String?
    let startTime: Timestamp?
    let endTime: Timestamp?
    let spacing: CGFloat?
    let size: CGFloat?
    let lineLimit: Int?
    
    
    
    
    
    init(
        category: String,
        originPlaceName: String? = nil,
        originPlaceAddress: String? = nil,
        destinationPlaceName: String? = nil,
        destinationPlaceAdress: String? = nil,
        startTime: Timestamp? = nil,
        endTime: Timestamp? = nil,
        spacing: CGFloat? = nil,
        size: CGFloat? = nil,
        lineLimit : Int? = nil
    ) {
        self.category = category
        self.originPlaceName = originPlaceName
        self.originPlaceAddress = originPlaceAddress
        self.destinationPlaceName = destinationPlaceName
        self.destinationPlaceAdress = destinationPlaceAdress
        self.startTime = startTime
        self.endTime = endTime
        self.spacing = spacing
        self.size = size
        self.lineLimit = lineLimit
    }
    
    
    var body: some View{
        
        
        
        HStack{
            VStack(alignment: .leading, spacing: 10){
                
                switch category{
                    
                case ListingCategory.event.rawValue:
                    
                    timeDisplayer(category: category, startTime: startTime, endTime: endTime , size: size)
                    LocationDisplayer(text: "Where:", place: originPlaceName, address: originPlaceAddress, spacing: spacing, size: size)
                    
                case ListingCategory.ride.rawValue ,  ListingCategory.shopping.rawValue:
                    
                    timeDisplayer(category: category, startTime: startTime, endTime: endTime , size: size)
                    LocationDisplayer(text: category == ListingCategory.ride.rawValue ? "From:" :"Shop from:", place: originPlaceName, address: originPlaceAddress , spacing: spacing, size: size)
                    LocationDisplayer(text: category == ListingCategory.ride.rawValue ? "To:" :"Deliver to:", place: destinationPlaceName, address: destinationPlaceAdress , spacing: spacing, size: size)
                    
                    
                case ListingCategory.sublease.rawValue:
                    
                    timeDisplayer(category: category, startTime: startTime, endTime: endTime , size: size)
                    LocationDisplayer(text: "Address:", place: originPlaceName, address: originPlaceAddress , spacing: spacing, size: size)
                    
                default:
                    EmptyView()
                    
                }
            }
            .foregroundColor(.black)
            
            Spacer()
        }
        
        .padding(.vertical, 5)
      
    }
    
  
    
    
    @ViewBuilder
    func timeDisplayer(category: String, startTime: Timestamp?, endTime: Timestamp?, size: CGFloat? = nil) -> some View{
        
        
        
        Group{
            if let startTime = startTime{
                
                let (date1, time1) = TimeFormatter.shared.textTimeformatter(startTime)
                
                switch category{
                    
                case ListingCategory.event.rawValue:
                    
                    if let endTime = endTime{
                        let (date2, time2) = TimeFormatter.shared.textTimeformatter(endTime)
                        
                        if date1 == date2{
                            Text("When: ")
                                .font(.system(size: size ?? 14, weight: .bold))
                            
                            +
                            Text("\(date1)  from \(time1) to \(time2)")
                        }else{
                            Text("Begining: \(date1)  at: \(time1)")
                            Text("Until: \(date2)  at: \(time2)")
                        }
                        
                    }
                    
                    
                case ListingCategory.sublease.rawValue:
                    
                    if let endTime = endTime{
                        let (date2, time2) = TimeFormatter.shared.textTimeformatter(endTime)
                       
                        Text("Start: ")
                            .font(.system(size: size ?? 14, weight: .bold))
                        +
                        Text("\(date1)")
                        
                        +
                        
                        Text(" | End: ")
                            .font(.system(size: size ?? 14, weight: .bold))
                        +
                        Text("\(date2)")
                        
                    }
                    
                case ListingCategory.ride.rawValue,  ListingCategory.shopping.rawValue:
                    
                    Text("Time & Date: ")
                        .font(.system(size: size ?? 14, weight: .bold))
                    +
                    Text("\(date1)  at: \(time1)")
                    
                    
                default:
                    EmptyView()
                }
            }
        }
        .font(.system(size: size ?? 14, weight: .semibold))
        .foregroundColor(.black)


    }
    
 
}



struct LocationDisplayer: View{
    
    let text: String
    let place: String?
    let address: String?
    let spacing: CGFloat?
    let size: CGFloat?
    let lineLimit: Int?
    
    
    init(
        text: String,
        place: String? = nil,
        address: String? = nil,
        spacing: CGFloat? = nil,
        size: CGFloat? = nil,
        lineLimit : Int? = nil
    ) {
        self.text = text
        self.place = place
        self.address = address
        self.spacing = spacing
        self.size = size
        self.lineLimit = lineLimit
    }
    
    
    var body: some View{
        
        if let place = place , let address = address{
            
            VStack(alignment: .leading, spacing: spacing ?? 2){
                
                Group{
                    Text(text)
                        .font(.system(size: size ?? 14, weight: .bold))
                    
                    +
                    
                    Text(" \(place)")
                        .font(.system(size: size ?? 14, weight: .semibold))

                }
                .lineLimit(lineLimit ?? 1)
                
                
                Text(address)
                    .font(.system(size: size ?? 14, weight: .light))
                    .foregroundColor(.blue)
                    .lineLimit(lineLimit ?? 1)
                
                
            }
            .foregroundColor(.black)

        }
    }
}


struct Listingdescription: View{
    let description: String?
    let hasImages: Bool
    var body: some View{
        
        if let description = description {
            
            HStack{
                Text(description)
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .semibold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(hasImages ? 3 : 7)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                
                Spacer()
            }
        }
    }
}


struct ListingCellBottomBar: View{
    
    @EnvironmentObject var session: AuthenticationViewModel
    @State var showQuestionView: Bool = false
    @StateObject var viewModel : ListingCellviewModel
    @State var showSharePostVew = false
    @State  var settingsDetent = PresentationDetent.medium
    @State var showChatbox: Bool = false
    @StateObject  var homeIndex = HomeIndex.shared
    let screenWidth = UIScreen.main.bounds.width
    @Binding var path: NavigationPath

    
    var body: some View{
        HStack{
            Button(action: {
                
                if let user = viewModel.listing.user{
                    homeIndex.messageFrom = .listing
                    homeIndex.listing = viewModel.listing
                    homeIndex.chatTargetUser = user
                    homeIndex.currentIndex = 1
                   
                }
                
            }, label: {
                Image(systemName: "ellipsis.message")
                
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(maxWidth: screenWidth * 0.125)
                    .background(Color.white)
                    .clipShape(CustomCorners(radius: 25, corners: [.bottomRight, .topRight]))
                
                    .shadow(radius: 5)
                
            })
            .navigationDestination(isPresented: $showChatbox) {
                
                if let user = viewModel.listing.user{
                    ChatBoxView(chatClosed: .constant(""), closeNewMessage: .constant(false), path: $path)
                        .environmentObject(ChatViewModel(currentUser: viewModel.currentUser, otherUser: user))
                        .environmentObject(session)
                }
            }
            
            Spacer()
            
           
                
                Button(action: {
                    Task{
                        if viewModel.wasInterested{
                            try await viewModel.unLike()
                            
                        }else{
                            
                            try await viewModel.like()
                            
                        }
                    }
                    
                }, label: {
                    let interestedNumber = viewModel.listing.interestedNumber
                    Text("\(interestedNumber > 0 ? String(interestedNumber) : "") Interested")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background( viewModel.wasInterested ? .red : .white)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                    
                })
                
                Spacer()
                
                Button(action: {
                    
                    showQuestionView = true
                    
                }, label: {
                    let questionNumber = viewModel.listing.questionNumber
                    Text("\(questionNumber > 0 ? String(questionNumber)+" " : "") \(questionNumber == 1 ? "Question" : "Questions")")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                    
                })
            
                .sheet(isPresented: $showQuestionView) {
                    ListingQuestionView(listing: viewModel.listing)
                }
           
            Spacer()
            
            Button(action: {
                
                showSharePostVew = true
                
            }, label: {
                Image(systemName: "arrowshape.turn.up.forward")
                
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(maxWidth: screenWidth * 0.125)
                    .background(Color.white)
                    .clipShape(CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft]))
                
                    .shadow(radius: 5)
               
            })
            
            .sheet(isPresented: $showSharePostVew) {
                UsersToSendToView( sentUrl: .constant(""))
                    .environmentObject(SharePostViewModel(currentUser: session.dbUser, shareCategory: .listing, listing: viewModel.listing))
                    .presentationDetents(
                                        [.medium, .large],
                                        selection: $settingsDetent
                                     )
            }
           
        }
       
    }
    
}



struct ListingTimeAndLocationViewSmall: View{
    
    let category: String
    let originPlaceName: String?
    let originPlaceAddress: String?
    let destinationPlaceName: String?
    let destinationPlaceAdress: String?
    let startTime: Timestamp?
    let endTime: Timestamp?
    
    var body: some View{
        
        
        
        HStack{
            VStack(alignment: .leading, spacing: 10){
                
                switch category{
                    
                case ListingCategory.event.rawValue:
                    
                    timeDisplayer(category: category, startTime: startTime, endTime: endTime)
                    locationdisplayer(text: "Where:", place: originPlaceName, address: originPlaceAddress)
                    
                case ListingCategory.ride.rawValue ,  ListingCategory.shopping.rawValue:
                    
                    timeDisplayer(category: category, startTime: startTime, endTime: endTime)
                    locationdisplayer(text: category == ListingCategory.ride.rawValue ? "From:" :"Shop from:", place: originPlaceName, address: originPlaceAddress)
                    locationdisplayer(text: category == ListingCategory.ride.rawValue ? "To:" :"Deliver to:", place: destinationPlaceName, address: destinationPlaceAdress)
                    
                    
                case ListingCategory.sublease.rawValue:
                    
                    timeDisplayer(category: category, startTime: startTime, endTime: endTime)
                    locationdisplayer(text: "Address:", place: originPlaceName, address: originPlaceAddress)
                    
                default:
                    EmptyView()
                    
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
      
    }
    
   
    @ViewBuilder
    func locationdisplayer(text: String, place: String?, address: String?) -> some View{
        
        if let place = place , let address = address{
            
            VStack(alignment: .leading, spacing: 2){
                
                
                Text(text)
                    .font(.system(size: 12, weight: .bold))
                
                
                Text("\(place)")
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                
                Text(address)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.blue)
                    .lineLimit(1)
               
            }
            .foregroundColor(.black)

        }
    }
    
    
    
    @ViewBuilder
    func timeDisplayer(category: String, startTime: Timestamp?, endTime: Timestamp?) -> some View{
        
       
        Group{
            if let startTime = startTime{
                
                let (date1, time1) = TimeFormatter.shared.textTimeformatter(startTime)
                
                switch category{
                    
                case ListingCategory.event.rawValue:
                    
                    if let endTime = endTime{
                        let (date2, time2) = TimeFormatter.shared.textTimeformatter(endTime)
                        
                        if date1 == date2{
                            VStack(alignment: .leading , spacing: 2){
                                Text("When: \(date1)")
                                    .font(.system(size: 12, weight: .bold))
                                
                                
                                Text("From \(time1) to \(time2)")
                            }
                        }else{
                            VStack(alignment: .leading , spacing: 2){
                                Text("Begining: \(date1)  at: \(time1)")
                                Text("Until: \(date2)  at: \(time2)")
                            }
                        }
                        
                    }
                    
                    
                case ListingCategory.sublease.rawValue:
                    
                    if let endTime = endTime{
                        let (date2, time2) = TimeFormatter.shared.textTimeformatter(endTime)
                       
                        VStack(alignment: .leading , spacing: 2){
                            Text("Start: ")
                                .font(.system(size: 12, weight: .bold))
                            +
                            Text("\(date1)")
                            
                            
                            
                            Text("End: ")
                                .font(.system(size: 12, weight: .bold))
                            +
                            Text("\(date2)")
                        }
                        
                    }
                    
                case ListingCategory.ride.rawValue,  ListingCategory.shopping.rawValue:
                    
                    VStack(alignment: .leading , spacing: 2){
                        Text("Time & Date: ")
                            .font(.system(size: 12, weight: .bold))
                        
                        Text("\(date1)  at: \(time1)")
                    }
                    
                default:
                    EmptyView()
                }
            }
        }
        .foregroundColor(.black)
        .font(.system(size: 12, weight: .semibold))

    }
    
    
  
}





