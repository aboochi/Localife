//
//  PlaceSearchResultView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//

import SwiftUI

struct PlaceSearchResultView: View {
    
    @StateObject var viewModel: CreateListingViewModel
    let placeType: PlaceType
    var body: some View {
        
        
            List(viewModel.placeSearchResults, id: \.self) { mapItem in
                    Button(action: {
                        if placeType == .origin{
                            viewModel.originPlace = (mapItem.name ?? "", mapItem.placemark.title ?? "")
                            
                            if let locationResults = viewModel.getLocationAndGeohash(mapItem: mapItem){
                                (viewModel.originLocation, viewModel.originGeoHash5, viewModel.originGeoHash6, viewModel.originGeoHash7) = locationResults
                            }
                            
                        }else{
                            viewModel.destinationPlace = (mapItem.name ?? "", mapItem.placemark.title ?? "")
                            
                            if let locationResults = viewModel.getLocationAndGeohash(mapItem: mapItem){
                                (viewModel.destinationLocation, viewModel.destinationGeoHash5, viewModel.destinationGeoHash6, viewModel.destinationGeoHash7) = locationResults
                            }
                        }
                        viewModel.showPlaceResults = false
                    }) {
                        VStack(alignment: .center) {
                            Text(mapItem.name ?? "")
                            Text(mapItem.placemark.title ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                
                        }
                    }
                
            }
        }
        
        
    }



