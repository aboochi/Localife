//
//  ListingCellFullView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//

import SwiftUI
@_spi(Experimental) import MapboxMaps


struct ListingCellFullView: View {
    
    
    @EnvironmentObject var session: AuthenticationViewModel
    @State var showSharePostVew = false
    @State  var settingsDetent = PresentationDetent.medium
    
    @Environment(\.dismiss)  var dismiss
    @EnvironmentObject var viewModel: ListingCellviewModel
    let screenWidth = UIScreen.main.bounds.width
    @State var message: String = "Hi, is this still available?"
    @State var isLineLimited: Bool = true
    @State var showQuestionView = false
    @State var messageSent: Bool = false
    @State var showRestrictionOption: Bool = false
    
    @ObservedObject  var homeIndex = HomeIndex.shared

   
    @Binding var  currentItemIndex: Int
    @Binding var presentFullView: Bool

    
    @State var showProfile: Bool = false
    
    @State var currentPage: Int = 0
    @State  var currentZoom = 1.0
    @State var anchorPoint: UnitPoint = .center
    @State var path = NavigationPath()
    
    var hasNoImageOrMap: Bool{
        if let urls = viewModel.listing.urls{
            return urls.count == 0 && viewModel.listing.originLocation == nil
        }else if viewModel.listing.originLocation == nil{
            return true
        }else{
            return false
        }
    }
    
    var body: some View {
      
            VStack{
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading){
                        
                        if let urls = viewModel.listing.urls, urls.count > 0{
                            //
                            MediaSlideViewML(urls: urls, id: viewModel.listing.id, aspectRatio: viewModel.listing.aspectRatio, mediaCategory: .listing, currentPage: $currentPage , playedPostIndex: .constant(0), postIndex: 0 ,  currentZoom: $currentZoom)
                                .scaleEffect(currentZoom , anchor: anchorPoint)
                                .zIndex(1)
                                .modifier(ZoomModifier(currentZoom: $currentZoom, anchorPoint: $anchorPoint))
                            
                            
                                .frame(width: screenWidth  , height: screenWidth / viewModel.listing.aspectRatio)
                        }else if viewModel.listing.originLocation != nil {
                            
                            MarketMapView(listing: viewModel.listing, dimension: (screenWidth, CGFloat(250)))
                                .environmentObject(viewModel)
                        }
                        
                        titleAndforwardButton
                        
                        VStack(alignment: .leading){
                            
                            
                            price
                                .padding(.vertical, 10)
                            
                            HStack{
                                
                              
                               
                            AvatarView(photoUrl: viewModel.listing.user?.photoUrl, username: viewModel.listing.user?.username, size: 40)
                                
                                    .onTapGesture {
                                        showProfile = true
                                    }
                                    
                               
                                
                                stats
                            }
                            .padding(.vertical, 12)
                            
                            timeAndLocationNeccessary
                            
                            description
                            
                            
                            questionAndInterestedButtons
                                .padding(.top, 10)
                            
                            
                            if viewModel.listing.ownerUid != session.dbUser.id{
                                messageBox
                            }
                            
                            if let urls = viewModel.listing.urls, urls.count > 0, viewModel.listing.originLocation != nil{
                                
                                MarketMapView(listing: viewModel.listing , dimension: (screenWidth - 20, CGFloat(200)))
                                    .environmentObject(viewModel)
                            }
                            
                            timeAndLocationOptional
                            
                            
                            
                        }
                        .padding(.horizontal, 10)
                        
                        
                    }
                    
                    
                }
                .refreshable {
                    Task{
                        try await viewModel.fetchListing()
                    }
                }
                
                Spacer()
            }
            .overlay(
            topBar
            ,alignment: .top
            )
            
            
            
            .sheet(isPresented: $showProfile) {
                
                NavigationStack(path: $path){
                    let user = DBUser(uid: viewModel.listing.ownerUid, username: "placeholder")
                    ProfileView(viewModel: ProfileViewModel(user: user, currentUser: session.dbUser),  listingViewModel: ListingViewModel(user: user), path: $path, isPrimary: false)
                        .environmentObject(session)
                }
            }
            
            
        
       
        
        
       // .navigationBarTitleDisplayMode(.inline)
       // .navigationBarItems(trailing: trailingBar)
       // .navigationBarHidden(true)
        
        .onAppear{
            
            homeIndex.marketPreviousPage = homeIndex.marketcurrentPage
            homeIndex.marketcurrentPage = .full
        }
        
        .onChange(of: session.dbUser.hiddenPostIds) { oldValue, newValue in
            if session.dbUser.hiddenPostIds.contains(viewModel.listing.id){
                dismiss()
                presentFullView = false
            }
        }
        
       
        
        
        
        
        
        
    }
    
    var leadingBar: some View {
        Button {
            dismiss()
            
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white))
                .shadow(radius: 5)
                
        }
    }

    var trailingBar: some View {
        Button {
            
            showRestrictionOption =  true

        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .rotationEffect(.degrees(90))
               .frame(width: 40, height: 40)
               .background(Circle().fill(Color.white))
               .shadow(radius: 5)

                
        }
        
        .sheet(isPresented: $showRestrictionOption, content: {
            if let user = viewModel.listing.user{
                RestrictionOptionsView(viewModel: ProfileViewModel(user: user, currentUser: session.dbUser), showOptions: $showRestrictionOption, contentCategory: .listing, contentId: viewModel.listing.id, listing: viewModel.listing, postCaption: nil)
                    .environmentObject(session)
                    .presentationDetents([session.dbUser.id == viewModel.listing.ownerUid ?  .height(150) :   .height(270)])
            }
        })
    }
    
    var topBar: some View{
        HStack{
            leadingBar
            Spacer()
            trailingBar
        }
        .padding(10)
    }
        
    
    var titleAndforwardButton: some View{
        
        HStack{
            title
            Spacer()
            
            Button(action: {
                showSharePostVew = true
                
            }, label: {
                Image(systemName: "arrowshape.turn.up.right")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .semibold))
                    .padding(10)
            })
            
           
        }
        .padding(.top, hasNoImageOrMap ?  70 : 0)
        
        .sheet(isPresented: $showSharePostVew) {
            UsersToSendToView( sentUrl: .constant(""))
                .environmentObject(SharePostViewModel(currentUser: session.dbUser, shareCategory: .listing, listing: viewModel.listing))
                .presentationDetents(
                                    [.medium, .large],
                                    selection: $settingsDetent
                                 )
        }

    }
    
    
    
    
    
    @ViewBuilder
    var title: some View{
        
        
        
        HStack{
            Text(viewModel.listing.title)
                .padding(10)
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .semibold))
            
            Spacer()
        }
        .frame(maxWidth: screenWidth * 0.8)
        .background(Rectangle().fill(
            LinearGradient(
              gradient: Gradient(colors: [Color.gray.opacity(0.15), Color.white.opacity(1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        )
        
    }
    
    
    @ViewBuilder
    var stats: some View{
        
        HStack(alignment: .top){
           
            VStack(alignment: .leading, spacing: 5){
                
                
                if let username = viewModel.listing.user?.username{
                    
                    
                    
                    NavigationLink {
                        let user = DBUser(uid: viewModel.listing.ownerUid, username: "placeholder")
                        ProfileView(viewModel: ProfileViewModel(user: user, currentUser: session.dbUser), listingViewModel: ListingViewModel(user: user),  path: .constant(NavigationPath()) , isPrimary: false)
                            .environmentObject(session)
                    } label: {
                        Text(username)
                            .foregroundColor(.black)
                            .font(.system(size: 15, weight: .semibold))
                        
                            
                    }

                  
                   
                }
                    
                Text("\(viewModel.listing.interestedNumber > 0 ? String(viewModel.listing.interestedNumber) + " Interested " : "")")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .light))
                    +
                    
                Text("\(viewModel.listing.questionNumber > 0 ? " · " + String(viewModel.listing.questionNumber) + "Questions · " : "")")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .light))
                    +
                    
                Text("\(TimeFormatter.shared.timeAgoFormatter(time: viewModel.listing.time))")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .light))
                    
                }
                
           
        }
    }
    
    
    
    
    @ViewBuilder
    var description: some View{
        
        if let description = viewModel.listing.description, description.count > 0{
            Text(description)
                .foregroundColor(.black)
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.leading)
                .lineLimit(isLineLimited ? 3 : 100)
                .padding(.vertical, 3)
                .onTapGesture {
                    isLineLimited = false
                }
            
        }
    }
    
    
    @ViewBuilder
    var price: some View{
        
        Group{
            if let price = viewModel.listing.price, price > 0{
                
                let priceString = TimeFormatter.shared.formattedPrice(price)
                switch viewModel.listing.category{
                case ListingCategory.sale.rawValue:
                    Text("Asked: $\(priceString)")
                    
                case ListingCategory.sublease.rawValue:
                    
                    Text("Monthly rent: $\(priceString)")
                    
                case ListingCategory.ride.rawValue, ListingCategory.pet.rawValue, ListingCategory.shopping.rawValue:
                    
                    Text("Suggested compensation: $\(priceString)")
                        .font(.system(size: 20, weight: .bold))

                    
                case ListingCategory.event.rawValue:
                    
                    Text("Ticket price: $\(priceString)")
                    
                default:
                    EmptyView()
                }
                
            }
        }
        .foregroundColor(.black)
        .font(.system(size: 22, weight: .bold))
        
    }
    
    
    
    @ViewBuilder
    var questionAndInterestedButtons: some View{
        
        HStack(spacing: 10){
            Button(action: {
                
                Task{
                    if viewModel.wasInterested{
                        try await viewModel.unLike()
                        
                    }else{
                        
                        try await viewModel.like()
                        
                    }
                }
                
              
                
            }, label: {
                actionbutton(text: "Interested", size: .infinity, color: viewModel.wasInterested ? .red : .white )
            })
            
            Button(action: {
                
                showQuestionView = true
                
            }, label: {
                actionbutton(text: "Questions", size: .infinity)
            })
            .sheet(isPresented: $showQuestionView) {
                    ListingQuestionView(listing: viewModel.listing)
                }
            
            
           // actionbutton(text: "Save", size: 100 )
            

        }
        .frame(maxWidth: .infinity)
    }
    
    
    @ViewBuilder
    func actionbutton(text: String, size: CGFloat = 150, color: Color = .white ) -> some View {
        
        HStack{
            Spacer()
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color == .white ? .black : .white)
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
            
            Spacer()
        }
            .frame(maxWidth: size)
            .background(CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft, .topRight, .bottomRight]).fill(color))
            
        
            .overlay(
                
                Group{
                    if color == .white{
                        CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft, .topRight, .bottomRight])
                            .stroke(Color.black.opacity(1), lineWidth: 1)
                    }
                }
            )
    }
    
@ViewBuilder
    var messageBox: some View{
       
            HStack{

                TextField("Write a message...", text: $message)
                    .padding(.horizontal, 15)
                    .frame( height: 40)
                    .frame(maxWidth: .infinity)
                    .background(CustomCorners(radius: 20, corners: [.bottomLeft, .topLeft, .topRight, .bottomRight]).fill(.gray.opacity(0.2)))
                
                    .overlay(
                        Group {
                            if messageSent {
                                Text("Message Sent")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .background(Color.green)
                                    .cornerRadius(15)
                                    .transition(.opacity)
                                    .padding(.horizontal, 10)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                messageSent = false
                                            }
                                        }
                                    }
                            }
                        }
                        , alignment: .trailing
                    )
                    .animation(.easeInOut, value: messageSent)

                HStack{
                    
                    Button(action: {
                        if !message.isEmpty{
                            Task{
                                do{
                                    try await viewModel.sendMesssage(text: message)
                                    message = ""
                                    messageSent = true

                                }
                            }
                        }
                    }, label: {
                        
                        Image(systemName: "paperplane.fill")
                            .scaleEffect(1.1)
                            //.font(.system(size: 18, weight: .semibold))
                            .frame( width: 40, height: 40)
                            .foregroundColor(.white)
                            .background(CustomCorners(radius: 20, corners: [.bottomLeft, .topLeft, .topRight, .bottomRight]).fill(.blue))
                        
                    })
                   
                   
              
                }
                
            }
            
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)

    }
    
    
    @ViewBuilder
    var timeAndLocationNeccessary: some View{
        
        ListingTimeAndLocationView(category: viewModel.listing.category, originPlaceName: viewModel.listing.originPlaceName, originPlaceAddress: viewModel.listing.originPlaceAddress, destinationPlaceName: viewModel.listing.destinationPlaceName, destinationPlaceAdress: viewModel.listing.destinationPlaceAdress, startTime: viewModel.listing.desiredTime, endTime: viewModel.listing.endTime, spacing: 3, size: 16)
        
            .background(Rectangle().fill(
                LinearGradient(
                  gradient: Gradient(colors: [Color.gray.opacity(0.15), Color.white.opacity(1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            )
       
    }
    
    @ViewBuilder
    var timeAndLocationOptional: some View{
        
        if viewModel.listing.category == ListingCategory.pet.rawValue || viewModel.listing.category == ListingCategory.other.rawValue || viewModel.listing.category == ListingCategory.sale.rawValue{
            
            LocationDisplayer(text: "Location:", place: viewModel.listing.originPlaceName, address: viewModel.listing.originPlaceAddress , spacing: 5, size: 16)
        }
    }
    
    
}

