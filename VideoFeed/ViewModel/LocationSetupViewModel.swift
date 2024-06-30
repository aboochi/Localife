//
//  LocationSetupViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/23/24.
//

import Foundation
import CoreLocation
import Combine
import GeohashKit
import MapKit




@MainActor
final class LocationSetupViewModel: ObservableObject {
    
    var locationManager: LocationManager? {
        didSet{
            
            subscribeToLocation()
        }
    }
    @Published var location: CLLocationCoordinate2D?
    @Published var locationUpdated: Bool = false
    @Published var locationSearchQuery: String = ""
    @Published var placeSearchResults: [MKMapItem] = []
    @Published var place: (String, String)?
    @Published var accessStatus: locationAccessStatusEnum = .intitial


    let user: DBUser
    
    
    private var cancellables = Set<AnyCancellable>()

    init(user: DBUser){
        self.user = user
    }
    
    func subscribeToLocation() {
        locationManager?.$location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLocation in
               
                    self?.location = newLocation
                    self?.locationUpdated.toggle()
                
                
          
            }
            .store(in: &cancellables)
    }
    
    func subscribeToLocationStatus() {
        locationManager?.$accessStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLocation in
               
                    self?.accessStatus = newLocation
                    
                
                
          
            }
            .store(in: &cancellables)
    }
    
    func saveLocation() async throws{
        
       
        if let location = location{
            try await UserManager.shared.updateLocation(userId: user.id, location: location)
        }
    }
}
