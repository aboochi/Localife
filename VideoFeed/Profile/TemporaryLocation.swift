//
//  TemporaryLocation.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/22/24.
//

import SwiftUI

struct TemporaryLocation: View {
    @StateObject  var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("Location: \(location.latitude), \(location.longitude)")
            } else {
                Text("Fetching location...")
            }

            Button("Request Location") {
                locationManager.requestLocation()
            }
        }
        .padding()
        .onAppear {
            locationManager.requestLocation()
        }
        .alert(isPresented: .constant(locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted)) {
            Alert(
                title: Text("Location Access Denied"),
                message: Text("Please enable location services in Settings"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}




#Preview {
    TemporaryLocation()
}
