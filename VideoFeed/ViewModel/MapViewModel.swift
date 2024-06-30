//
//  MapViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/31/24.
//

import Foundation
import FirebaseFirestore
import CoreLocation
import SwiftUI



@MainActor
final class MapViewModel: ObservableObject{
    
    @Published var users : [DBUser] = []
    @Published var showAnnotation = false
    
    @Published var selectedUser: DBUser? = nil
    @Published var selectedListing: [String : Listing] = [:]
    
    @Published var listingViewModels: [String : ListingViewModel] = [:]
    
   // @Published var isVisible : [String: Bool] = [:]

    func setZoom(_ zoom: Double) {
                var showAnnotation = zoom < 12
                if showAnnotation != self.showAnnotation {
                    // OK, the showAnnotation updates only when actual value changed.
                    // The `body` will be executed once per update.
                   
                        self.showAnnotation = showAnnotation
                   
                }
            }
    
//    func setVisible(_ visible: Bool, uid: String){
//        if let visibility = isVisible[uid] , visibility != visible{
//            self.isVisible[uid] = visible
//        }
//    }
    
    var userLocation : CLLocationCoordinate2D? {
        if let geoPoint = currentUser.location{
            return convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
        }else{
            return nil
        }
        
    }
    
    var lastDocument: DocumentSnapshot?
    
    let currentUser: DBUser
    
    init(currentUser: DBUser){
        self.currentUser = currentUser
        Task{
            try await fetchNeighbors()
        }
    }
    
    
    
    func fetchNeighbors() async throws{
        
        if users.count > 0 && lastDocument == nil{ return }
        
        if let location = userLocation{
            let fetchedResult = try await UserManager.shared.getUsersByLocation(location: location, count: 20, lastDocument: lastDocument)
            users = fetchedResult.output
            lastDocument = fetchedResult.lastDocument
            
            for  user in users{
                listingViewModels[user.id] = ListingViewModel(user: user)
            }
            print("number of fetched user by location:  >>>>>>>>\(users.count)")
        }
    }
    
    func convertGeoPointToCLLocationCoordinate2D(geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    
    
    func fetchListing(listingId: String) async throws -> Listing? {
        

            return try await ListingManager.shared.getListing(listingId: listingId)

    }
    
    
    
    func fetchUserActiveListing(user: DBUser) async throws -> Listing?{
        
        let fetchResult = try await ListingManager.shared.getListingsActiveByTimeAndUid(count: 2, uid: user.id, lastDocument: nil)

       
        return fetchResult.output.first
    }
    
    
    func fetchAndsetListingOwner(FetchedListings: [Listing]) async throws -> [Listing]{
        var outPutListing : [Listing] = []
        for var listing in FetchedListings{
            do{
                try await listing.setUserOwner()
            }catch{
                continue
            }
        }
        return outPutListing
    }
    
}
