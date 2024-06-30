//
//  ListingPlacePicker.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//

import SwiftUI
import MapKit


struct ListingPlacePicker: View {
    
    @StateObject var viewModel: CreateListingViewModel
    let placeType: PlaceType
    let listing: Listing?
    
    
    var body: some View {
        
       
        
        HStack{
            
            switch placeType{
                
            case .origin:
                VStack(alignment: .leading){
                    HStack{
                        Text(firstLocationText)
                        TextField("Search for a place", text: $viewModel.originSearchQuery, onCommit: {searchForPlace(placeType: .origin)})
                    }
                    if let originPlace = viewModel.originPlace{
                        Text("\(originPlace.0) | \(originPlace.1)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
            case .destination:
                VStack(alignment: .leading){
                    HStack{
                        Text(secondLocationText)
                        TextField("Search for a place", text: $viewModel.destinationSearchQuery, onCommit: {searchForPlace(placeType: .destination)})
                    }
                    if let originPlace = viewModel.destinationPlace{
                        Text("\(originPlace.0) | \(originPlace.1)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
        }
        
      
        .onAppear{
            
            
            if let first = listing?.originPlaceName, let second = listing?.originPlaceAddress{
                viewModel.originPlace = (first, second)
            }
            if let first = listing?.destinationPlaceName, let second = listing?.destinationPlaceAdress{
                viewModel.destinationPlace = (first, second)
            }

        }

       
    }
    
    
    
    private func searchForPlace( placeType: PlaceType) {
        print("function search for place called")
        let request = MKLocalSearch.Request()
        if placeType == .origin{
            request.naturalLanguageQuery = viewModel.originSearchQuery
        } else{
            request.naturalLanguageQuery = viewModel.destinationSearchQuery

        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                if let error = error {
                    print("Error searching for place: \(error.localizedDescription)")
                }
                return
            }
            
            

            viewModel.placeSearchResults = response.mapItems
            viewModel.placeType = placeType
            viewModel.showPlaceResults = true
            
            if placeType == .origin{
                viewModel.originSearchQuery = ""
            } else{ viewModel.destinationSearchQuery = ""
            }
            
                
        }
    }
    
    
    
    
    
    var firstLocationText: String {
        var text: String
        switch viewModel.selectedCategory{
        case ListingCategory.ride.rawValue:
            text = "From:"
        case ListingCategory.shopping.rawValue:
            text = "Shop from: "
        case ListingCategory.sublease.rawValue:
            text = "Address:  "
        case ListingCategory.event.rawValue:
            text = "Where"
        default:
            text = "Location"
        }
        
        return text
    }
    
    
    var secondLocationText: String {
        var text: String
        switch viewModel.selectedCategory{
        case ListingCategory.ride.rawValue:
            text = "To:    "
        case ListingCategory.shopping.rawValue:
            text = "Delivere to:"
        default:
            text = "Location"
        }
        
        return text
          
    }
    
    
    
}


