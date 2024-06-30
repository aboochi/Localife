//
//  UserSearchViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/2/24.
//

import Foundation
import Combine
import FirebaseFirestore
import CoreLocation


@MainActor
final class UserSearchViewModel: ObservableObject{
    
    @Published var searchString: String = ""
   
    var lastDocumentUserTime: DocumentSnapshot?
    var lastDocumentUserNeighbor: DocumentSnapshot?
    var lastDocumentUserSearch: DocumentSnapshot?
    
    @Published var usersTime: [DBUser] = []
    @Published var usersNeighbor: [DBUser] = []
    @Published var usersSearch: [DBUser] = []

    
    @Published var user: DBUser
    
    private var cancellables = Set<AnyCancellable>()
        
    init(user: DBUser) {
        self.user = user
            observeSearchString()
        }
    
    
    private func observeSearchString() {
            $searchString
                .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .sink { [weak self] newValue in
                    if newValue != ""{
                        
                        Task {
                            self?.usersSearch = []
                            self?.lastDocumentUserSearch = nil
                            try await self?.fetchUsers(search: newValue.lowercased())
                        }
                    }else{
                        self?.usersSearch = []
                    }
                }
                .store(in: &cancellables)
        }
    
    
    func fetchUsers(search: String) async throws{
        if (usersSearch.count > 0 && lastDocumentUserSearch == nil) || search == "" { return }
        
        let fetchedResult = try await UserManager.shared.getUsersByName(strSearch: search, count: 10, lastDocument: nil)
        lastDocumentUserSearch = fetchedResult.lastDocument
        usersSearch = fetchedResult.output
        
      
    }
    
    func fetchMoreUsers() async throws{
        if (usersSearch.count > 0 && lastDocumentUserSearch == nil) || searchString == "" { return }
        
        let fetchedResult = try await UserManager.shared.getUsersByName(strSearch: searchString, count: 10, lastDocument: lastDocumentUserSearch)
        lastDocumentUserSearch = fetchedResult.lastDocument
        usersSearch.append(contentsOf: fetchedResult.output)

    }
    
 
    func fetchUsersByTime() async throws{
        if lastDocumentUserTime == nil && usersTime.count > 0 {return}
        
        Task{
            let fetchedUsers = try await UserManager.shared.getUsersByTime(count: 10, lastDocument: lastDocumentUserTime)
            lastDocumentUserTime = fetchedUsers.lastDocument
            let  filteredUsers = fetchedUsers.output.filter({ Set(usersNeighbor.map { $0.id }).contains($0.id)})
            usersTime.append(contentsOf: filteredUsers)
        }
    }
    
    
    
    func fetchNeighborUsers() async throws{
        if lastDocumentUserNeighbor == nil && usersNeighbor.count > 0 {return}
        
        Task{
            if let location = userLocation{
                let fetchedUsers = try await UserManager.shared.getUsersByLocation(location: location, count: 20, lastDocument: lastDocumentUserNeighbor)
                lastDocumentUserNeighbor = fetchedUsers.lastDocument
                usersNeighbor.append(contentsOf: fetchedUsers.output)
            }
        }
    }
    
    var userLocation : CLLocationCoordinate2D? {
        if let geoPoint = user.location{
            return convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
        }else{
            return nil
        }
        
    }
    
    func convertGeoPointToCLLocationCoordinate2D(geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    

}


