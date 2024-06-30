//
//  SendPostViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/31/24.
//

import Foundation
import FirebaseFirestore
import CoreLocation
import Combine



enum ShareCategoryEnum{
    case post
    case story
    case listing
    case message
   
}


@MainActor
final class SharePostViewModel: ObservableObject{
    @Published var users: [DBUser] = []
    let currentUser: DBUser
    let shareCategory: ShareCategoryEnum
    var lastDocument: DocumentSnapshot?
    let post: Post?
    let listing: Listing?
    let story: Story?
    let forwardedMessage: Message?
    
    @Published var searchText: String = ""
    @Published var usersSearch: [DBUser] = []
    var lastDocumentUserSearch: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    var userLocation : CLLocationCoordinate2D? {
        if let geoPoint = currentUser.location{
            return convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
        }else{
            return nil
        }
        
    }
    
    
    init(currentUser: DBUser, shareCategory: ShareCategoryEnum, post: Post? = nil, listing: Listing? = nil, story: Story? = nil ,forwardedMessage: Message? = nil){
        self.currentUser = currentUser
        self.shareCategory = shareCategory
        self.post = post
        self.listing = listing
        self.story = story
        self.forwardedMessage = forwardedMessage
        
        observeSearchString()
        
        Task{
            try await fetchUsers()
        }
    }
    
    
    
    private func observeSearchString() {
            $searchText
                .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .sink { [weak self] newValue in
                    if newValue != ""{
                        
                        Task {
                            do{
                                self?.usersSearch = []
                                self?.lastDocumentUserSearch = nil
                                try await self?.fetchSearchUsers(search: newValue.lowercased())
                                
                            }
                        }
                    }else{
                        self?.usersSearch = []
                    }
                }
                .store(in: &cancellables)
        }
    
    
    
    func fetchSearchUsers(search: String) async throws{
        if (lastDocumentUserSearch == nil && usersSearch.count > 0) || search == "" {return}
        
        do{
            let fetchedResults = try await UserManager.shared.getUsersByName(strSearch: search, count: 10, lastDocument: nil)
            lastDocumentUserSearch = fetchedResults.lastDocument
            var fetchedUsers = fetchedResults.output
            fetchedUsers.removeAll(where: {$0.id == currentUser.id})
            //usersSearch.filter({$0.id == currentUser.id})
            usersSearch.append(contentsOf: fetchedUsers)
        }
    }
    
    
    
    
    
    
    
    
    func fetchUsers() async throws{
        
        if users.count > 0 && lastDocument == nil{ return }
        
        if let location = userLocation{
            let fetchedResult = try await UserManager.shared.getUsersByLocation(location: location, count: 20, lastDocument: lastDocument)
            var fetchedUsers = fetchedResult.output
            fetchedUsers.removeAll(where: {$0.id == currentUser.id})
            
            users = fetchedUsers
            lastDocument = fetchedResult.lastDocument
            
            
        }else{
            
            let fetchedUsers = try await UserManager.shared.getUsersByTime(count: 20, lastDocument: lastDocument)
            lastDocument = fetchedUsers.lastDocument
            users.append(contentsOf: fetchedUsers.output)
        }
    }
    
    
    
    func share( recipientUser: DBUser) async throws{
        
        
        let messageId = UUID().uuidString
        
        if var message = forwardedMessage{
            message.id = messageId
            message.recipientId = recipientUser.id
            message.ownerId = currentUser.id
            message.time = Timestamp()
            message.ownerPhotoUrl = currentUser.photoUrl
            message.ownerUsername = currentUser.username ?? "unknown"
            message.recipientPhotoUrl = recipientUser.photoUrl
            message.recipientUsername = recipientUser.username ?? "unknown"
            message.isReply = false
            message.isHidden = false
            message.isReplyToPost = false
            message.isReplyToListing = false

            message.isForwarded = true
            
            do{
                
                try await MessageManager.shared.sendMessage(message: message, otherUser: recipientUser)
                try await MessageManager.shared.markDeliver(message: message)
            }
            
        }else{
            
            
            
            
            var message = Message(id: messageId, ownerId: currentUser.id, recipientId: recipientUser.id, text: "", ownerPhotoUrl: currentUser.photoUrl, ownerUsername: currentUser.username ?? "unknown", recipientPhotoUrl: recipientUser.photoUrl, recipientUsername: recipientUser.username ?? "unknown", sharedPostId: sharedId)
            
            switch shareCategory {
            case .post:
                message.isPost = true
                
                if let post = post, let thumbnail = post.thumbnailUrls.first {
                    message.sharedPostThumbnail = thumbnail
                    message.sharedPostIsVideo = thumbnail.contains("postVideos")
                    message.sharedPostAspectRatio = post.aspectRatio
                    message.sharedPostOwnerUsername = post.ownerUsername
                    message.sharedPostOwnerPhotoUrl =  post.ownerPhotoUrl
                    message.sharedPostCaption = post.caption
                }
                
            case .story:
                message.isStory = true
                
            case .listing:
                message.isListing = true
                
                if let listing = listing{
                    message.sharedPostThumbnail = listing.thumbnailUrls?.first
                    message.sharedPostAspectRatio = 1
                    message.sharedPostOwnerUsername = listing.ownerUsername
                    message.sharedPostOwnerPhotoUrl =  listing.ownerPhotoUrl
                    if let thumbnail = listing.thumbnailUrls?.first{
                        message.sharedPostIsVideo = thumbnail.contains("listingVideos")
                        
                    }
                }
                
            case .message:
      print("")
            }
            do{
                
                try await MessageManager.shared.sendMessage(message: message, otherUser: recipientUser)
                try await MessageManager.shared.markDeliver(message: message)
            }
            
        }
    }
    
    
    func convertGeoPointToCLLocationCoordinate2D(geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    
    var sharedId: String? {
        switch shareCategory{
            
        case .post:
            return self.post?.id
        case .story:
            return self.story?.id
        case .listing:
            return self.listing?.id
        case .message:
            return self.forwardedMessage?.id
        }
    }
}
