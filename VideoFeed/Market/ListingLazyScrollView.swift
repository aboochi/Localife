//
//  ListingLazyScrollView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/5/24.
//


enum ListingTypeEnum{
    case expired
    case active
    case explore
    case otherUser
    case interest
    case main
    case full
    case keywordSearch
}

import SwiftUI

struct ListingLazyScrollView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ListingViewModel
    @State var playedPostIndex: Int = 0
    @State var appearedPostIndecis: [Int] = [-2, -1, 0, 1, 2]
    @State var scrollTo: String?
    let userId: String
    let listingType: ListingTypeEnum
    let screenWidth = UIScreen.main.bounds.width
    //@Environment(\.dismiss) var dismiss
    @Binding var path: NavigationPath
    @ObservedObject  var homeIndex = HomeIndex.shared
    @State var isNotTop: Bool = false
    @State var presentFullView: Bool = false
    @State var indexToGo: Int = 0
    @State var selectedListing: Listing?

    
    var body: some View {
        
       
            ScrollViewReader{ proxy in
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0){
                        
                        if listings(listingType).count < 1{
                            
                            
                            Text("Nothing to see yet 😔")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                                .padding()
                                .frame(width: screenWidth * 0.8, height: 600)
                                .background(.white)
                                
                            
                        }
                        
                        ForEach(Array(listings(listingType).enumerated()), id: \.element.id){ index, listing in
                            
                            
                            
                            
                            ListingCoverCell(listing: listing, path: $path , appearedPostIndecis: $appearedPostIndecis, playedPostIndex: $playedPostIndex, currentItemIndex: index)
                                .frame(width: screenWidth )
                                .modifier(Lazymodifier(playedPostIndex: $playedPostIndex, appearedPostIndecis: $appearedPostIndecis, isNotTop: $isNotTop, index: index, action: {
                                    
                                }))
                            
                                .padding(.bottom, 20)
                                .id(index)
                                .onTapGesture {
                                    
                                    if !session.dbUser.hiddenPostIds.contains(listing.id){
                                        indexToGo = index
                                        selectedListing = listing
                                        presentFullView = true
                                    }
                                    
                                }
                            
                                .fullScreenCover(item: $selectedListing) { listing in
                                           
                                          
                                    ListingCellFullView( currentItemIndex: $indexToGo, presentFullView: $presentFullView)
                                        .environmentObject(ListingCellviewModel(currentUser: session.dbUser, listing: listing))
                                        }
                            
                               
                            
                            
                            
                        }
                        
                        
                        if listings(listingType).count > 6{
                            
                            Button {
                                
                                fetchMore(listingType)
                                
                            } label: {
                                Text("See more")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(Capsule().fill(.gray.opacity(0.2)))
                                    .padding(.horizontal)
                            }

                           
                        }
                        
                    }
                    
                    
                    .onDisappear {
                        switch listingType{
                            
                        case .expired:
                            homeIndex.marketcurrentPage = .main
                        case .active:
                            
                            homeIndex.marketcurrentPage = .main
                            
                        case .explore:
                            
                            homeIndex.marketcurrentPage = .main
                            
                        case .otherUser:
                            
                            print("")
                            
                        case .interest:
                            
                            homeIndex.marketcurrentPage = .main
                            
                            
                        case .main:
                            print("")
                            
                        case .full:
                            
                            print("")
                        case .keywordSearch:
                            print("")
                        }
                        
                    }
                    
                    
                    
                    
                    .onAppear{
                        
                        
                        
                        if let scrollTo = scrollTo{
                            proxy.scrollTo(scrollTo, anchor: .center)
                            
                            if listingType == .otherUser{
                                Task{
                                    viewModel.listingActiveOtherUser = []
                                    viewModel.lastDocumentActiveOtherUser = nil
                                    try await viewModel.fetchOtherUserActiveListing(uid: userId)
                                    
                                }
                            }
                        }
                    }
                    
                }
                .modifier(ListingScrollTopModifier(listingType: listingType, isNotTop: $isNotTop, action: {
                    
                    withAnimation{
                        proxy.scrollTo(0)
                    }
                }) )
                
                
          
            .navigationBarBackButtonHidden()
            
        }
        
    }
    
    
    func fetchMore(_ listingType: ListingTypeEnum) {
        Task{
            switch listingType {
            case .expired:
                try await viewModel.fetchUserExpiredListing()
            case .active:
                try await viewModel.fetchUserActiveListing()
            case .explore:
                try await viewModel.fetchUserExploreListing()
            case .otherUser:
                print("")
            case .interest:
                try await viewModel.fetchUserInterestListing()
            case .main:
                print("")
            case .full:
                print("")
            case .keywordSearch:
                print("")
            }
        }
    }
    
    
    
    func listings(_ listingType: ListingTypeEnum) -> [Listing]{
        
        switch listingType {
        case .expired:
            return viewModel.listingExpired
        case .active:
            return viewModel.listingActive
        case .explore:
            return viewModel.listingExplore
        case .otherUser:
            return viewModel.listingActiveOtherUser
        case .interest:
            return viewModel.listingInterest
        case .main:
            return viewModel.listingExplore
        case .full:
            return viewModel.listingExplore
        case .keywordSearch:
            return viewModel.listingKeywords
        }
    }
    

}




struct Lazymodifier: ViewModifier{
    
    @Binding var playedPostIndex: Int
    @Binding var appearedPostIndecis: [Int]
    @Binding var isNotTop: Bool
    let index: Int
    
    
    let action: () -> Void
    func body(content: Content) -> some View {
        content
        
            .background(
                GeometryReader{ geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global)) { oldValue, newValue in
                            
                            if !isNotTop && oldValue.midY > newValue.midY {
                                isNotTop = true
                            }
                            
                            
                            if newValue.minY > -100 && newValue.maxY < 1200 {
                                playedPostIndex = index
                                action()
                            }
                            if (index - 2) % 3 == 0 && appearedPostIndecis[2] != index && newValue.minY < 900 && newValue.maxY > -50 {
                                withAnimation{
                                    appearedPostIndecis  = [ index-2, index-1, index, index+1, index+2]
                                }
                                
                               
                                
                            }
                            
                           // print("playedPostIndex   >>>>>>>>>>>>>>>>>>>. \(playedPostIndex)")

                            
                        }
                }
            )
        
    }
}


struct ListingScrollTopModifier: ViewModifier{
    
    let listingType: ListingTypeEnum
    @EnvironmentObject var viewModel:  ListingViewModel
    @ObservedObject  var homeIndex = HomeIndex.shared
    @Binding var isNotTop: Bool
    let action: () -> Void



    
    func body(content: Content) -> some View {
        
        switch listingType {
        case .expired:
            
            content
            
                .refreshable {
                    
                    
                    Task{
                        do{
                            viewModel.listingExpired = []
                            viewModel.lastDocumentExpired = nil
                            try await viewModel.fetchUserExpiredListing()
                        }
                    }
                    
                }
                .onChange(of: isNotTop) { oldValue, newValue in
                    if newValue{
                        homeIndex.marketExpiredGoTop = false
                        homeIndex.marketcurrentPage = .expired
                    }
                }
                .onChange(of: homeIndex.marketExpiredGoTop) { oldValue, newValue in
                    if newValue{
                        action()
                        isNotTop = false

                    }
                }
        case .active:
               
            content
                .refreshable {
                    
                    Task{
                        do{
                            viewModel.listingActive = []
                            viewModel.lastDocumentActive = nil
                            try await viewModel.fetchUserActiveListing()
                        }
                    }
                    
                }
                .onChange(of: isNotTop) { oldValue, newValue in
                    
                    
                    if newValue{
                        homeIndex.marketActiveGoTop = false
                        homeIndex.marketcurrentPage = .active
                    }
                }
                .onChange(of: homeIndex.marketActiveGoTop) { oldValue, newValue in
                    if newValue{
                        action()
                        isNotTop = false
                    }
                }
        case .explore:
            content
                .refreshable {
                    
                    Task{
                        do{
                            viewModel.listingExplore = []
                            viewModel.lastDocumentExplore = nil
                            try await viewModel.fetchUserExploreListing()
                        }
                    }
                    
                }
            
            
                .onChange(of: isNotTop) { oldValue, newValue in
                    if newValue{
                        //homeIndex.marketExploreGoTop = false
                        homeIndex.marketcurrentPage = .explore

                    }
                }
                .onChange(of: homeIndex.marketExploreGoTop) { oldValue, newValue in
                    if newValue{
                        action()
                        isNotTop = false

                    }
                }
        case .otherUser:
            
            
            content
               
                .onChange(of: isNotTop) { oldValue, newValue in
                    if newValue{
                        homeIndex.marketOtherUserGoTop = false
                        homeIndex.marketcurrentPage = .otherUser

                    }
                }
                .onChange(of: homeIndex.marketOtherUserGoTop) { oldValue, newValue in
                    if newValue{
                        action()
                        isNotTop = false

                    }
                }
        case .interest:
            
               
            content
                .refreshable {
                    
                    
                    Task{
                        do{
                            viewModel.listingInterest = []
                            viewModel.lastDocumentInterest = nil
                            try await viewModel.fetchUserInterestListing()
                        }
                    }
                    
                }
                .onChange(of: isNotTop) { oldValue, newValue in
                    if newValue{
                        homeIndex.marketInterestedGoTop = false
                        homeIndex.marketcurrentPage = .interest

                    }
                }
                .onChange(of: homeIndex.marketInterestedGoTop) { oldValue, newValue in
                    if newValue{
                        action()
                        isNotTop = false

                    }
                }
        case .main:
            content
                .onChange(of: isNotTop) { oldValue, newValue in
                    if newValue{
                        homeIndex.marketMainGoTop = false
                        homeIndex.marketcurrentPage = .main

                    }
                }
                .onChange(of: homeIndex.marketMainGoTop) { oldValue, newValue in
                    if newValue{
                        action()
                        isNotTop = false

                    }
                }
            
        case .full:
            
            content
        case .keywordSearch:
            content
        }
    }
}
