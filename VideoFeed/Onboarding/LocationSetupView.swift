//
//  LocationSetupView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/16/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import GeohashKit

struct LocationSetupView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @StateObject var viewModel: LocationSetupViewModel
    @State var showPlaceResults: Bool = false
    @State private var settingsDetent = PresentationDetent.medium
    @State var showLocationPicker: Bool = false
    @Binding var selection: Int
    
   
    var body: some View {
        VStack() {
            
            
            if !showLocationPicker{
                
                accessLocationText
                    .padding(.horizontal, 5)
                
                locationConsentButtons
                
            }else{
                
                pickLocationManaully
            }
            
         
            
        }
        .padding()
        .onChange(of: viewModel.locationUpdated) { oldValue, newValue in
            Task{
                if viewModel.location != nil{
                    do{
                        try await viewModel.saveLocation()
                        session.userViewModel.dbUser =  try await session.userViewModel.getDBUser()
                        
                        
                        if let status = viewModel.locationManager?.accessStatus, status == .authorizedAlways ||  status == .authorizedWhenInUse{
                        
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01){
                                goNextStep()
                            }
                        }
                    }catch{
                        
                            goNextStep()
                       
                        
                    }
                }
            }
        }
        
        
        .onChange(of: viewModel.locationManager?.accessStatus, { oldValue, newValue in
            if newValue == .denied || newValue == .restricted{
                
                print(" location access status changed >>>>>>>>>>>>> \(newValue?.rawValue)")
                showLocationPicker = true
            }
        })
        
        .sheet(isPresented: $showPlaceResults, content: {
            PlaceSearchResultsView()
                .presentationDetents(
                                    [.medium, .large],
                                    selection: $settingsDetent
                                 )
        })

    }
    
    
    var pickLocationManaully: some View{
        
        VStack(spacing: 10){
            
            Text("You can also manually select a location.")
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .semibold))
                .padding(.bottom, 5)
            
            TextField("Search for a place", text: $viewModel.locationSearchQuery, onCommit: {searchForPlace()})
                .padding()
                .frame(maxHeight: 45)
                .background(Capsule().fill(.white.opacity(0.6)))
                .overlay(
                    Capsule()
                        .stroke(.white, lineWidth: 1)
                )
            
            if let place = viewModel.place{
                
                VStack(alignment: .leading){
                    
                    HStack{
                        
                        VStack(alignment: .leading, spacing: 1){
                            Text(place.0)
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .semibold))
                            Text(place.1)
                                .foregroundColor(.black)
                                .font(.system(size: 14, weight: .regular))
                        }
                        Spacer()
                        
                    }

                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.5))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .stroke(.black.opacity(0.5), lineWidth: 1)
                )
                
                
                Button {
                    goNextStep()
                } label: {
                    Text("Set this location")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(.black.opacity(0.5)))
                        .padding()
                }

               
            }
        }
    }
    
    
    
    func goNextStep(){
        var stage = session.onBoardingStage.rawValue
        if stage < 3{
            withAnimation(.easeInOut(duration: 0.5)){
                stage += 1
                let newStage = OnboaringStage(rawValue: stage)
                session.onBoardingStage = newStage ?? .done
            }
            Task{
                try await session.updateUserOnboardingState(onBoardingState:stage)
                HapticManager.shared.generateFeedback(of: .notification(type: .success))
                
            }
        }
    }
    
    
    private func searchForPlace( ) {
        print("function search for place called")
        let request = MKLocalSearch.Request()
       
        request.naturalLanguageQuery = viewModel.locationSearchQuery
       
         
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                if let error = error {
                    print("Error searching for place: \(error.localizedDescription)")
                }
                return
            }
            
            

            viewModel.placeSearchResults = response.mapItems
            
            showPlaceResults = true
            
            viewModel.locationSearchQuery = ""
            
                
        }
    }
    
    
    
    
    @ViewBuilder
    func PlaceSearchResultsView() -> some View{
        
        
        List(viewModel.placeSearchResults, id: \.self) { mapItem in
                Button(action: {
                   
                    viewModel.place = (mapItem.name ?? "", mapItem.placemark.title ?? "")
                        
                    if let location = mapItem.placemark.location?.coordinate{
                            viewModel.location = location
                        }
                        
                    
                    showPlaceResults = false
                    viewModel.locationUpdated = true
                }) {
                    VStack(alignment: .leading) {
                        Text(mapItem.name ?? "")
                        Text(mapItem.placemark.title ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                    }
                }
            
        }
    }
    
    
    
    @ViewBuilder
    var locationConsentButtons: some View{
        
        HStack(spacing: 15){
            
            
            Button(action: {
                showLocationPicker = true
            }, label: {
                Text("Maybe later")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background( CustomCorners(radius: 25, corners: [.topLeft, .bottomLeft]).fill(.white.opacity(0.7)))
                    .overlay(
                        CustomCorners(radius: 25, corners: [.topLeft, .bottomLeft])
                            .stroke(.black.opacity(0.3), lineWidth: 0)
                    )
                    
            })

            
            
            
            
            Button(action: {
                
                viewModel.locationManager = LocationManager()
              
            }, label: {
                Text("Sure")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(CustomCorners(radius: 25, corners: [.topRight, .bottomRight]).fill(.black.opacity(0.5)))
                    .overlay(
                        CustomCorners(radius: 25, corners: [.topRight, .bottomRight])
                            .stroke(.white.opacity(0.0), lineWidth: 1)
                    )
                   
            })
            
            
            
           
        }
        .padding(.horizontal, 5)
        .padding(.top, 5)
    }

    
    @ViewBuilder
    var accessLocationText: some View{
        
        VStack(alignment: .center) {
            Text("Allow Location Access")
                .font(.headline)
                .padding(.bottom, 5)
               

            
            Text("Would you like to allow location access for better service and connecting with neighbors?")

                .font(.system(size: 16, weight: .regular))
                .multilineTextAlignment(.center)
           
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .stroke(.black.opacity(0.5), lineWidth: 1)
        )

    }
    
    
}


