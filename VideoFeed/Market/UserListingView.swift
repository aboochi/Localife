//
//  UserListingView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/9/24.
//

import SwiftUI

struct UserListingView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ListingViewModel
    @EnvironmentObject var messageViewModel: MessageViewModel
    @ObservedObject  var homeIndex = HomeIndex.shared
    @Binding var path: NavigationPath
    
    @State  var selectedTab = "Active"
    let tabs = ["Active", "Expired"]

    
   
    @State var showCreateListing: Bool = false

    
    
    var body: some View {
        VStack{
            
    
            Picker("", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            if viewModel.completedUploadingSteps != -1{
                UploadProgressBar(uploadAllSteps: viewModel.uploadAllSteps, uploadCompletedSteps: viewModel.completedUploadingSteps)
            }

            
            switch selectedTab{
            case tabs[0]:
                
//                ListingScrollWrapper( scrollTo: nil, userId: session.dbUser.id, listingType: .active, path: $path)
//                    .environmentObject(viewModel)
                
                
                ListingLazyScrollView( scrollTo: nil, userId: session.dbUser.id, listingType: .active, path: $path)
                    .environmentObject(viewModel)
            case tabs[1]:
                
//                ListingScrollWrapper( scrollTo: nil, userId: session.dbUser.id, listingType: .expired, path: $path)
//                    .environmentObject(viewModel)
                
                ListingLazyScrollView( scrollTo: nil, userId: session.dbUser.id, listingType: .expired, path: $path)
                    .environmentObject(viewModel)
            default:
                
                EmptyView()
            }
           
       
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: leadingButton, trailing: trailingButtons)

        
        
        .onChange(of: showCreateListing, { oldValue, newValue in
            
            print("show create listing changed: \(newValue)")
            print("uplaod all steps: \(viewModel.uploadAllSteps)")
            if newValue == false && viewModel.uploadAllSteps == 1{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                    
                    viewModel.createListingViewModel = nil
                }

            }
        })
        
        .onChange(of: viewModel.completedUploadingSteps) { oldValue, newValue in
            print("completedUploadingSteps new listing: \(newValue)")
            if newValue == viewModel.uploadAllSteps{
                Task{
                    if let listingId = viewModel.uploadedListingId{
                        try await viewModel.fetchListingAddToActive(listingId: listingId)
                        
                        DispatchQueue.main.async {
                            
                            viewModel.completedUploadingSteps = -1
                            viewModel.uploadAllSteps = 1
                        }
                        viewModel.createListingViewModel = nil
                    }
                }
            }
        }

      
    }
    
  
    
    @ViewBuilder
    var leadingButton: some View{
        
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
    
    
    @ViewBuilder
    var trailingButtons: some View{
        
        HStack{
            
            
            Button(action: {
                if viewModel.createListingViewModel == nil{
                    viewModel.createListingViewModel = CreateListingViewModel(user: session.dbUser)
                }
                showCreateListing = true
            }, label: {
                Image(systemName: "plus.app.fill")
                    .foregroundColor(.blue)
                    .scaleEffect(1.2)
            })
            .fullScreenCover(isPresented: $showCreateListing, content: {
                CreateListingView(showCreateListing: $showCreateListing , formType: .create, listing: nil)
                    .environmentObject(viewModel.createListingViewModel ?? CreateListingViewModel(user: session.dbUser))
            })

            
            
            
            
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

