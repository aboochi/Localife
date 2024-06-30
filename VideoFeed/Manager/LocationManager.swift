//
//  LocationManager.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/22/24.
//

import Foundation
import CoreLocation

enum locationAccessStatusEnum: String{
    case notDetermined = "notDetermined"
    case restricted =  "restricted"
    case denied = "denied"
    case authorizedWhenInUse = "authorizedWhenInUse"
    case authorizedAlways = "authorizedAlways"
    case intitial = "initial"
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var accessStatus: locationAccessStatusEnum = .intitial

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
    }

    func requestLocation() {
            DispatchQueue.global().async {
                if CLLocationManager.locationServicesEnabled() {
                    DispatchQueue.main.async {
                        self.manager.requestLocation()
                    }
                } else {
                    print("Location services are not enabled")
                }
            }
        }

     func checkAuthorizationStatus() {
        let status = manager.authorizationStatus
        authorizationStatus = status
        
        switch status {
        case .notDetermined:
            accessStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
        case .restricted:
            accessStatus = .restricted
            print("Location access  restricted")
        case .denied:
            accessStatus = .denied
            print("Location access denied ")
        case .authorizedWhenInUse:
            accessStatus = .authorizedWhenInUse
            print("Location access authorizedWhenInUse")
            manager.requestLocation()
        case .authorizedAlways:
            accessStatus = .authorizedAlways
            print("Location access authorizedAlways")
            manager.requestLocation()
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
}
