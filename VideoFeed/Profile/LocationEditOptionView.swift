//
//  LocationEditOptionView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/23/24.
//

import SwiftUI

struct LocationEditOptionView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: LocationSetupViewModel
    
    let cellHeight = 37.0
    @State var showLocationDeniedAlert: Bool = false

    var body: some View {
        
        List{
            
            Section{
               
                    
                    
                Button {
                    
                    viewModel.locationManager = LocationManager()
                    viewModel.subscribeToLocationStatus()
                    //viewModel.locationManager?.checkAuthorizationStatus()
                    
                } label: {
                    Label("Update Location Automatically", systemImage: "location.north")
                        .frame(height: cellHeight)
                }

               
                   
               
                Text("Allow the app to access your current location. Follow the prompts to grant location permissions and automatically update your location on the server.")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.gray)
            }
            
            Section{
                NavigationLink {
                    
                    UpdateLocationManuallyView()
                        .environmentObject(session)
                        .environmentObject(viewModel)
                    
                } label: {
                    Label("Update Location Manually", systemImage: "location.magnifyingglass")
                        .frame(height: cellHeight)
                }
                Text("Manually enter your location. Provide the required details to update your location information on the server without relying on automatic detection.")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.gray)
            }
            
            
//            Section{
//                NavigationLink {
//                    
//                } label: {
//                    Label("Delete Stored Location", systemImage: "location.slash")
//                        .frame(height: cellHeight)
//                    
//                }
//                Text("Remove your current location information from the server. Confirm your choice to delete your stored location data and reset your location settings.")
//                    .font(.system(size: 12, weight: .light))
//                    .foregroundColor(.gray)
//            }
            
            
            
            
        }
        .navigationTitle("Location")
        
        
        .onChange(of: viewModel.location) { oldValue, newValue in
            Task{
                if viewModel.location != nil{
                    do{
                        try await viewModel.saveLocation()
                        session.userViewModel.dbUser =  try await session.userViewModel.getDBUser()
                        print("location saved")
                    }catch{
                        print("failed")
                        
                    }
                }
            }
        }
        
        .onChange(of: viewModel.accessStatus) { oldValue, newValue in
 
                         if let status = viewModel.locationManager?.accessStatus, status == .denied || status == .restricted{
                            
                            print("location saved inside setthing")
                            showLocationDeniedAlert = true
                        }
                   
                
            
        }
        
        .alert(isPresented: $showLocationDeniedAlert) {
                    Alert(
                        title: Text("Location Access Denied"),
                        message: Text("Your location settings do not allow us to access your location. Please go to settings to change it."),
                        primaryButton: .default(Text("Go to Settings"), action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                                viewModel.locationManager = nil
                                viewModel.accessStatus = .intitial
                                showLocationDeniedAlert = false
                            }
                        }),
                        secondaryButton: .cancel(Text("Dismiss"), action: {
                            viewModel.locationManager = nil
                            viewModel.accessStatus = .intitial
                            showLocationDeniedAlert = false


                        })
                    )
                }
        
        
        
    }
}

