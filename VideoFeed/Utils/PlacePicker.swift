//
//  PlacePicker.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/10/24.
//

import SwiftUI
import MapKit
import Foundation

struct PlacePicker: View {
    @State  var selectedPlace: MKPlacemark?
    @State private var searchQuery: String = ""
    @Binding  var searchResults: [MKMapItem]
    @Binding var showResults: Bool
    

    
    var body: some View {
        VStack {
            TextField("Search for a place", text: $searchQuery, onCommit: searchForPlace)
               // .textFieldStyle(RoundedBorderTextFieldStyle())
                //.padding(.top, 20)
                .overlay(
                    Button(action: searchForPlace) {
                        Image(systemName: "magnifyingglass")
                    }
                        
                    ,alignment: .trailing
                )
            
  
            Spacer()
        }
        
        
    }
    
    private func searchForPlace() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                if let error = error {
                    print("Error searching for place: \(error.localizedDescription)")
                }
                return
            }
            
            searchResults = response.mapItems
           
            showResults = true
            
            searchQuery = ""
        }
    }
}
