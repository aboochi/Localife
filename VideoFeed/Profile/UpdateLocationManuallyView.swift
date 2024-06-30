//
//  UpdateLocationManuallyView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/24/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import GeohashKit

struct UpdateLocationManuallyView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: LocationSetupViewModel
    @State var showPlaceResults: Bool = false
    @Environment(\.dismiss) var dismiss
    @State var showSaveAlert: Bool = false
    @State var showSuccess: Bool = false
    @State var updatedUser: DBUser?

    var body: some View {
        VStack{
            
            if showSuccess{
                
                
                Text("You are all set")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .fill(.white)
                            .shadow(radius: 10)
                        )
                    .padding()
                    .onAppear{
                        session.userViewModel.dbUser = updatedUser
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
                            dismiss()
                        }
                    }
                
                
            }else{
                pickLocationManaully
                Spacer()
            }
            
        }
       
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: backButton)
        
        .sheet(isPresented: $showPlaceResults, content: {
            PlaceSearchResultsView()
                .presentationDetents(
                                    [.medium, .large]
                                    
                                 )
        })
        
        .onChange(of: viewModel.locationUpdated) { oldValue, newValue in
            Task{
                if viewModel.location != nil{
                    do{
                       // try await viewModel.saveLocation()
                       // session.userViewModel.dbUser =  try await session.userViewModel.getDBUser()
                        
                        
                    }catch{
                       
                    }
                }
            }
        }
        
        .alert(isPresented: $showSaveAlert) {
                    Alert(
                        title: Text("Location Change Not Saved"),
                        message: Text("Your location change has not been saved. Do you want to save it before leaving?"),
                        primaryButton: .default(Text("Save"), action: {
                            Task{
                                do{
                                    try await viewModel.saveLocation()
                                    updatedUser =  try await session.userViewModel.getDBUser()
                                    showSuccess = true
                                }catch{
                                    dismiss()
                                }
                            }
                        }),
                        secondaryButton: .cancel(Text("Discard"), action: {
                            // Code to discard the location change and leave
                           dismiss()
                        })
                    )
                }
        
      
    }
    
    
    var pickLocationManaully: some View{
        
       List(){
           Section("pick a location"){
               
               
               
               
               TextField("Search for a place", text: $viewModel.locationSearchQuery, onCommit: {searchForPlace()})
                   .padding()
                   .frame(maxHeight: 45)
                   .background(Capsule().fill(.white.opacity(0.6)))
                   .overlay(
                    Capsule()
                        .stroke(.gray.opacity(0.5), lineWidth: 1)
                   )
               
               
               Button {
                   
                   searchForPlace()
                   
               } label: {
                   Text("Search")
                       .foregroundColor(.white)
                       .font(.system(size: 16, weight: .semibold))
                       .padding()
                       .frame(maxWidth: .infinity)
                       .background(Capsule().fill(viewModel.locationSearchQuery.isEmpty ? .blue.opacity(0.2) : .blue.opacity(1)))
                      
               }
               
               .disabled(viewModel.locationSearchQuery.isEmpty)
               
               
               
               Text("It could be as precise as your home address, as general as your neighborhood, or as broad as the city you live in. Rest assured, we will not share your exact location with anyone, regardless of the option you choose.")
                   .foregroundColor(.gray)
                   .font(.system(size: 14, weight: .regular))
                   .multilineTextAlignment(.leading)
           }
           
           
              
           
            
            
            
            
            if let place = viewModel.place{
                
                Section("selected place"){
                    
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
                            .stroke(.gray.opacity(0.5), lineWidth: 1)
                    )
                    
                    
                    Button {
                        
                        Task{
                            if viewModel.location != nil{
                                do{
                                    try await viewModel.saveLocation()
                                    updatedUser =  try await session.userViewModel.getDBUser()
                                    showSuccess = true
                                }catch{
                                    dismiss()
                                }
                            }
                        }
                        
                        
                        
                    } label: {
                        Text("Set this location")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(.blue.opacity(1)))
                           
                    }
                    
                }
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
    var backButton: some View{
        
        Button {
            
            if viewModel.place != nil{
                showSaveAlert = true
            }else{
                dismiss()
            }
            
        } label: {
            Label("Back", systemImage: "chevron.backward")
                .font(.system(size: 18, weight: .semibold))
        }

    }
    
    
}


