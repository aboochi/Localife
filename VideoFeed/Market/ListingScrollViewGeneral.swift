//
//  ListingScrollViewGeneral.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/14/24.
//

import SwiftUI




struct ListingScrollViewGeneral: View {
    
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
    @State var indexToGo: Int = 0
    @State var presentFullView: Bool = false
    @State var selectedListing: Listing?


    
    var body: some View {
       
      
        ScrollViewReader{ proxy in
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 50){
                    
                        
                    
                        ForEach(Array(viewModel.listingActiveOtherUser.enumerated()), id: \.element.id){ index, listing in
                            
                        
                            
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
                    
                    
                    if viewModel.listingActiveOtherUser.count > 6{
                        
                        Button {
                            Task{
                                try await viewModel.fetchOtherUserActiveListing(uid: userId)
                            }
                            
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
                
                
                .onChange(of: viewModel.listingActiveOtherUser, { oldValue, newValue in
                    print("newValue.count: >>>>>>>>>>>>>>>> \(newValue.count)")
                })
              
                .onAppear{
                    
                    Task{
                        if listingType == .main{
                            try await viewModel.fetchOtherUserActiveListing(uid: viewModel.user.id)
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if let scrollTo = scrollTo {
                            proxy.scrollTo(scrollTo, anchor: .center)
                        }
                    }
                    
     
                    
                }
                    
                }
            .refreshable {
                Task{
                        viewModel.listingActiveOtherUser = []
                        viewModel.lastDocumentActiveOtherUser = nil
                        try await viewModel.fetchOtherUserActiveListing(uid: viewModel.user.id)
                        print("refresh called inside general")
                }
            }
//            .modifier(ListingScrollTopModifier(listingType: listingType, isNotTop: $isNotTop, action: {
//                
//                withAnimation{
//                    proxy.scrollTo(0)
//                }
//            }) )
            
            }
        .navigationBarBackButtonHidden()
        
        }
    
    
    

    

}




