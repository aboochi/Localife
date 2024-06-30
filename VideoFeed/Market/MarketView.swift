//
//  MarketView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/9/24.
//

import SwiftUI



struct MarketNavigationValue: Hashable {
    var name: MarketNavigationEnum
    var listingId: String
    var userId: String
}

struct MarketView: View {
    
    @EnvironmentObject var messageViewModel: MessageViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @StateObject var viewModel: ListingViewModel
    @State var showCreateListing: Bool = false
    @ObservedObject  var homeIndex = HomeIndex.shared
    @State var listingId: String = ""
    @State var userId: String = ""
    @Binding var path: NavigationPath
    @State var presentSearchable: Bool = false


  
    let spacing = (UIScreen.main.bounds.width * 0.1) / 3
    var body: some View {
        
        
        ScrollViewReader{ proxy in
            
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    
                    navigationButtons
                        .id(-1)
                        .background(
                            GeometryReader{ geo in
                                
                                Color.clear
                                   
                                    .onChange(of: geo.frame(in: .global).midY) { oldValue, newValue in
                                        
                                        if homeIndex.marketMainGoTop && oldValue > newValue{
                                            homeIndex.marketMainGoTop = false
                                        }
                                    }
                                
                            }
                        )
                    
                    
                    if viewModel.searchText.count < 1{
                        lazyGridExplore
                    }else{
                        lazyGridSearch
                    }
                    
                    fetchMorebutton
                    
                    Spacer()
                }
            }
            .searchable(text: $viewModel.searchText , isPresented: $presentSearchable)
            .refreshable {
                Task{
                    
                    viewModel.user = session.dbUser
                    presentSearchable = false
                    viewModel.searchText = ""
                    viewModel.listingExplore = []
                    viewModel.lastDocumentExplore = nil
                    try await viewModel.fetchUserExploreListing()

                }
            }
            
            .onChange(of: viewModel.searchText, { oldValue, newValue in
                viewModel.searchText = viewModel.searchText.lowercased()
            })
            
            .onAppear{
                
                if !viewModel.marketViewAppeared{
                    
                    Task{
                        try await viewModel.fetchUserExploreListing()
                        try await  viewModel.fetchUserActiveListing()
                        try await  viewModel.fetchUserExpiredListing()
                        viewModel.marketViewAppeared = true
                       
                    }
                }
           
            }
            .onChange(of: homeIndex.marketMainGoTop) { oldValue, newValue in
                
                
                if newValue {
                    
                    withAnimation{
                        proxy.scrollTo(-1)
                    }
                    
                }
            }
        }
            .navigationTitle("")
            .navigationBarItems(trailing: trailingBar)
        
            .modifier(Navigationmodifier(path: $path))
            
   
    }
    
    
    @ViewBuilder
    var fetchMorebutton: some View{
        
        
        if (viewModel.listingKeywords.count > 5 && viewModel.lastDocumentKeywords != nil) || (viewModel.listingKeywords.count < 1 && viewModel.listingExplore.count > 5 &&  viewModel.lastDocumentExplore != nil){
            Button(action: {
                Task{
                    if viewModel.listingKeywords.count > 0{
                        
                        try await viewModel.getListingsTimeAndKeywords()
                        
                    }else{
                        
                        try await viewModel.fetchUserExploreListing()
                    }
                }
            }, label: {
                Text("See more")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Capsule().fill(.gray.opacity(0.2)))
                    .padding(.horizontal)
            })
        }
    }
    
    
    
    var lazyGridExplore: some View{
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: 2), spacing: 0) {
            
            ForEach(viewModel.listingExplore, id: \.id){ listing in
                
                
                
                Button(action: {
                    listingId = listing.id
                    userId = listing.ownerUid
                    //path.append(MarketNavigationValue(name: .smallCell, listingId: listing.id, userId: listing.ownerUid))
                    
                    let value = NavigationValuegeneral(type: .smallCell, listing: listing, listingViewModel: viewModel)
                    path.append(value)
                    
                }, label: {
                    ListingCoverCellExplore(listing: listing)
                })
                .id(listing.id)
                
                
                
            }
            
            .frame(width: UIScreen.main.bounds.width)
            .frame(alignment: .center)
            .padding()
        }
        .padding(spacing)
    }
    
    var lazyGridSearch: some View{
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: 2), spacing: spacing) {
            
            ForEach(viewModel.listingKeywords, id: \.id){ listing in
                
                
                
                Button(action: {
                    listingId = listing.id
                    userId = listing.ownerUid
                    
                    
                    let value = NavigationValuegeneral(type: .keywordSearch, listing: listing , listingViewModel: viewModel)
                    path.append(value)
                   // path.append(MarketNavigationValue(name: .keywordSearch, listingId: listing.id, userId: listing.ownerUid))
                }, label: {
                    ListingCoverCellExplore(listing: listing)
                })
                .id(listing.id)
              
            }
            
            .frame(width: UIScreen.main.bounds.width)
            .frame(alignment: .center)
            .padding()
        }
        .padding(spacing)
    }
    
    
    
    var navigationButtons: some View{
        
        HStack(spacing: 15){
            
            
            Button {
                //path.append(MarketNavigationValue(name: .yourListing, listingId: "", userId: ""))
                
                let value = NavigationValuegeneral(type: .yourListing  , listingViewModel: viewModel, messageViewModel: messageViewModel)
                path.append(value)
                


            } label: {
                
                Text("Your Listings")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft])
                            .stroke(Color.black, lineWidth: 1)
                    )
                    
            }
            
            
            Button {
                if viewModel.createListingViewModel == nil{
                    viewModel.createListingViewModel = CreateListingViewModel(user: session.dbUser)
                }
                showCreateListing = true
            } label: {
                
                Image(systemName: "plus.app.fill")
                    .scaleEffect(2)
                    .foregroundColor(.blue)
            }
            
            .fullScreenCover(isPresented: $showCreateListing, content: {
                CreateListingView(showCreateListing: $showCreateListing , formType: .create, listing: nil)
                    .environmentObject(viewModel.createListingViewModel ?? CreateListingViewModel(user: session.dbUser))
            })

            
            
            Button {
                
                let value = NavigationValuegeneral(type: .yourInterest  , listingViewModel: viewModel)
                path.append(value)
                //path.append(  MarketNavigationValue(name: .yourInterest, listingId: "", userId: ""))
              
                
            } label: {
                
                Text("Your Interests")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        CustomCorners(radius: 25, corners: [.bottomRight, .topRight]) //[.bottomLeft, .topLeft, .bottomRight, .topRight]
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
            
            
           

       
        }
        .padding(.top, 15)
        .padding(.bottom, 10)
        .padding(.horizontal)
    }
    
    
    @ViewBuilder
    var trailingBar: some View{
        
        HStack{
            
            Button {
                HomeIndex.shared.currentIndex = 1
            } label: {
                
                Image(systemName: "ellipsis.message")
                    .foregroundColor(.black)
                    .overlay(
                        
                        Text("\(messageViewModel.unreadChats.count)")
                            .foregroundColor(messageViewModel.unreadChats.count > 0 ? .white : .clear)
                            .font(.system(size: 12))
                            .padding(6)
                            .background(messageViewModel.unreadChats.count > 0 ? .red : .clear)
                            .clipShape(Circle())
                            .frame(alignment: .topTrailing)
                            .offset(x: 8, y: -11)
                        
                        
                        ,alignment: .topTrailing
                    )
                
            }
        
            
  
        
          
            
        }
    }
    
    
}

import SwiftUI

struct ListingScrollWrapper<Content: View>: View {
    let scrollTo: String
    let userId: String
    let listingType: ListingTypeEnum
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ListingViewModel
    @ObservedObject var homeIndex = HomeIndex.shared
    @Binding var path: NavigationPath
    let content: (_ scrollTo: String?, _ userId: String, _ listingType: ListingTypeEnum, _ path: Binding<NavigationPath>) -> Content

    var body: some View {
        VStack {
            content(scrollTo, userId, listingType, $path)
                .environmentObject(viewModel)
        }
        .navigationBarItems(leading: leadingButton)
        .navigationBarBackButtonHidden()
    }

    @ViewBuilder
    var leadingButton: some View {
        Button {
            if path.count > 0 {
                path.removeLast()
            }
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .semibold))
        }
    }
}

