//
//  CreateListingModifier.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//

import SwiftUI

struct CreateListingModifier: ViewModifier{
    
    @StateObject var viewModel: CreateListingViewModel
    
    func body(content: Content) -> some View {
        content
            .onChange(of: viewModel.selectedDate, { oldValue, newValue in
                if viewModel.endDate < viewModel.selectedDate{
                    viewModel.adjustDate()
                }
               
      
            })
            
            .onChange(of: viewModel.endDate, { oldValue, newValue in
                
                if viewModel.endDate < viewModel.selectedDate{
                    viewModel.adjustDate()
                    
                }
            })
            
            .onChange(of: viewModel.selectedCategory, { oldValue, newValue in
                    
                viewModel.adjustDate()
                viewModel.resetErrorDisplay()
                viewModel.resetLocations()
                viewModel.resetImages()
                viewModel.resetTitleAndDescription()
                
                switch viewModel.selectedCategory{
                case ListingCategory.sublease.rawValue:
                    viewModel.selectedPrice = 500
                    viewModel.step = 50
                    viewModel.range = 100...3000
                case ListingCategory.sale.rawValue:
                    viewModel.selectedPrice = 50
                    viewModel.step = 5
                    viewModel.range = 5...200
                default:
                    viewModel.selectedPrice = 0
                    viewModel.step = 5
                    viewModel.range = 5...200
                }
                
             
            })
            
            .onChange(of: viewModel.originSearchQuery, { oldValue, newValue in
                viewModel.showOriginError = false
            })
            
            .onChange(of: viewModel.destinationSearchQuery, { oldValue, newValue in
                viewModel.showDestinationError = false
            })
            
            .onChange(of: viewModel.description, { oldValue, newValue in
                viewModel.showDescriptionError = false
            })
            
            .onChange(of: viewModel.selectedAssets, { oldValue, newValue in
                viewModel.showImageError = false
            })
           
            
            .sheet(isPresented: $viewModel.showPlaceResults, content: {
                PlaceSearchResultView(viewModel: viewModel, placeType: viewModel.placeType)
                    .presentationDetents(
                                        [.medium, .large],
                                        selection: $viewModel.settingsDetent
                                     )
            })
            .fullScreenCover(isPresented: $viewModel.showImagePicker, content: {
                
                ListingImagePickerView()
                    .environmentObject(viewModel.imagePickerViewModel ?? ImagePickerViewModel())
            })
            
            
            
        }
        
      
    }


