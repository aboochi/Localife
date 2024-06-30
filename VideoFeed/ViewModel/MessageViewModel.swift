//
//  MessageViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//

import Foundation
import Combine
import FirebaseFirestore
import CoreLocation


@MainActor
final class MessageViewModel: ObservableObject {
    
    var lastDocumentUserTime: DocumentSnapshot?
    var lastDocumentUserNeighbor: DocumentSnapshot?
    var lastDocumentUserSearch: DocumentSnapshot?


    
    @Published var chatBoxViewModels: [String: ChatViewModel] = [:]
    @Published var completedUploadingSteps: [String: [String: CGFloat]] = [:]
    private var childrenCancellables: [String: AnyCancellable] = [:]
    @Published var uploadAllSteps : [String: [String: CGFloat]] = [:]
    @Published var chatClosed: String?
    @Published var updateThisUI : Bool = false
    @Published var updatePreviewUI : Bool = false

    @Published var chats: [Message] = []
    @Published var chatUsers: [String: DBUser] = [:]
    @Published var unreadChats: [String: UnreadChat] = [:]


    @Published var usersTime: [DBUser] = []
    @Published var usersNeighbor: [DBUser] = []
    @Published var usersSearch: [DBUser] = []
    
    @Published var searchString: String = ""



     let user: DBUser
    private var cancellables = Set<AnyCancellable>()
    
    init(user: DBUser){
        self.user = user
        observeSearchString()
        Task{
             fetchChats()
             fetchUnreadChats()
        }
    
    }
    
    
    private func observeSearchString() {
            $searchString
                .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .sink { [weak self] newValue in
                    if newValue != ""{
                        
                        Task {
                            do{
                                self?.usersSearch = []
                                self?.lastDocumentUserSearch = nil
                                try await self?.fetchSearchUsers(search: newValue.lowercased())
                                print("search token:    >>>>>>>>>>>>>>>>>>> \(newValue)")
                                print("usersSearch    >>>>>>>>>>>   \(self?.usersSearch.count)")
                            }
                        }
                    }else{
                        self?.usersSearch = []
                    }
                }
                .store(in: &cancellables)
        }
    

    func subscribeToChildSteps(id: String) {
        // Remove previous subscriptions
       // cancellables.removeAll()
        if chatBoxViewModels[id] != nil{
            
            print("subscription is called")
            
            childrenCancellables[id] = chatBoxViewModels[id]!.$completedUploadingSteps.sink { [weak self] newStep in
                self?.completedUploadingSteps[id] = newStep
                print(" a new step is set:   \(newStep)")
                self?.updatePreviewUI.toggle()

            }
        }
    }
    
    func subscribeToChilduploadAllSteps(id: String) {
        if chatBoxViewModels[id] != nil{
            
            childrenCancellables["\(id)-1"] = chatBoxViewModels[id]!.$uploadAllSteps.sink { [weak self] newStep in
                self?.uploadAllSteps[id] = newStep
                print(" a uploadAllSteps is set:   \(newStep)")
            }
            
        }
    }
    
    
    
    func addChatViewModel(currentUser: DBUser, otherUser: DBUser) {
        
        chatBoxViewModels[otherUser.id] = ChatViewModel(currentUser: currentUser, otherUser: otherUser)
    }
    
    
    func reloadView() {
            objectWillChange.send()
        } 
    
    
    
    func fetchChats()  {
        
        MessageManager.shared.fetchChats(currentUser: user)
            .sink { completion in
                
            } receiveValue: { [weak self ] messages in
                //print("chats changed")
                self?.chats = messages
                
                self?.updateThisUI.toggle()
                
               
                
            }
            .store(in: &cancellables)

    }
    
    
    func fetchUnreadChats()  {
        
          MessageManager.shared.fetchUnreadChats(currentUid: user.id)
            .sink { completion in
                
            } receiveValue: { [weak self ] chats in
                //print("unreadchats changed >>>>>>>>> \(chats)")
                self?.unreadChats = chats
                
                self?.updateThisUI.toggle()
                
               
                
            }
            .store(in: &cancellables)

    }
    
    
    func fetchUsersByTime() async throws{
        if lastDocumentUserTime == nil && usersTime.count > 0 {return}
        
        Task{
            let fetchedUsers = try await UserManager.shared.getUsersByTime(count: 30, lastDocument: lastDocumentUserTime)
            lastDocumentUserTime = fetchedUsers.lastDocument
            let  filteredUsers = fetchedUsers.output.filter({ Set(usersNeighbor.map { $0.id }).contains($0.id)})
            usersTime.append(contentsOf: filteredUsers)
        }
    }
    
    
    
    func fetchNeighborUsers() async throws{
        if lastDocumentUserNeighbor == nil && usersNeighbor.count > 0 {return}
        
        Task{
            if let location = userLocation{
                let fetchedResult = try await UserManager.shared.getUsersByLocation(location: location, count: 30, lastDocument: lastDocumentUserNeighbor)
                lastDocumentUserNeighbor = fetchedResult.lastDocument
                
                var fetchedUsers = fetchedResult.output
                fetchedUsers.removeAll(where: {$0.id == user.id})
                
                
                usersNeighbor.append(contentsOf: fetchedUsers)
            }
        }
    }
    
    
    
    func fetchSearchUsers(search: String) async throws{
        if (lastDocumentUserSearch == nil && usersSearch.count > 0) || search == "" {return}
        
        do{
            let fetchedUsers = try await UserManager.shared.getUsersByName(strSearch: search, count: 20, lastDocument: nil)
            lastDocumentUserSearch = fetchedUsers.lastDocument
            usersSearch.append(contentsOf: fetchedUsers.output)
        }
    }
    
    
    func deleteChats(otherId: String) async throws{
        try await MessageManager.shared.deleteChats(currentId: user.id, otherId: otherId)
    }
    
    func setUserOwner(message: inout Message, uid: String) async throws {
        message.user = try await UserManager.shared.getUser(userId: uid)
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
