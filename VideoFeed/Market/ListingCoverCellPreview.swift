//
//  ListingCoverCell.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/11/24.
//

import SwiftUI
import FirebaseFirestore

struct ListingCoverCellPreview: View {
    
    
    @StateObject var viewModel: CreateListingViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding var showCreateListing: Bool

    let screenWidth: CGFloat = UIScreen.main.bounds.width
 
    let widthPortion: CGFloat = 0.9
    var imageScale: CGFloat {
        return viewModel.selectedCategory == ListingCategory.sale.rawValue ? 1 : (viewModel.selectedCategory == ListingCategory.shopping.rawValue ? 0.65 : 0.8)
        

    }
    var hasImages: Bool {
        if viewModel.selectedAssets.count > 0{
        return true
    }else{
        return false
    }
    }
    
    var body: some View {
        
        
        VStack{
            
            VStack{
                Spacer()
                Rectangle()
                    .foregroundColor(.clear)
            }
            .frame(maxHeight: .infinity)
            
           
        
            VStack{
                HStack(alignment: .top){
                    
                    ListingCellAvatarView(user: session.dbUser, time: Timestamp(), listing: nil)
                    Spacer()
                    ListingPriceView(price: viewModel.selectedPrice)
                    ListingCategoryView(category: viewModel.selectedCategory)
                    
                }
                .padding()
                
                ListingTitleView(title: viewModel.title, widthPortion: widthPortion)
                ListingTimeAndLocationView(category: viewModel.selectedCategory, originPlaceName: viewModel.originPlace?.0, originPlaceAddress: viewModel.originPlace?.1, destinationPlaceName: viewModel.destinationPlace?.0, destinationPlaceAdress: viewModel.destinationPlace?.1, startTime: Timestamp(date: viewModel.selectedDate), endTime: Timestamp(date: viewModel.endDate))
                
                    .padding(.horizontal)
                    
                
                if let imagePicker = viewModel.imagePickerViewModel, viewModel.selectedAssets.count > 0{
                    ImagePickerSlidePreview(viewModel: imagePicker)
                        .scaleEffect(widthPortion * 0.9)
                        .frame(width: screenWidth * widthPortion * 0.9 , height: screenWidth * widthPortion *  imageScale * 0.9)
                        .clipped()
                }
                
                   
                Listingdescription(description: viewModel.description, hasImages: hasImages)
               
                
            }
            .frame(width: screenWidth * widthPortion)
            .frame(maxHeight: screenWidth * widthPortion * 1.4)
            .foregroundColor(.black)
            .background(Color(hex: "#eaf6f6"))
            .cornerRadius(25)
            .shadow(radius: 10)
            
            
            
            VStack{
                Spacer()
                Rectangle()
                    .foregroundColor(.clear)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: screenWidth * widthPortion)
        

        
        .navigationBarTitle("Listing Preview", displayMode: .inline)
        .navigationBarItems(
            trailing:
                
                Button(action: {
                    Task{
                        try await viewModel.shareListing(formType: .create)
                    }
                    viewModel.imagePickerViewModel?.completedUploadingSteps = 0
                    viewModel.completedUploadingSteps = 0
                    showCreateListing = false
                    
                }, label: {
                    Text("Share")
                        .foregroundColor(.blue)
                })
            
            
        )
        
    }
    

    
   
}


