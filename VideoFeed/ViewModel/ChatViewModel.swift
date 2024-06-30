//
//  ChatViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class ChatViewModel: ObservableObject{
    
    @Published var fetchCount: Int = 100
    @Published var caption: String = ""

    @Published var messages: [Message] = []
    @Published var messageContent: String = ""
    var currentUser: DBUser
    var otherUser: DBUser
    @Published var listing: Listing?
    private var cancellables = Set<AnyCancellable>()
    
    var cancellable: AnyCancellable?
    
    @Published var showAlbum: Bool = false
    @Published var albumMessage: Message?

    @Published var repliedMessage: Message?
    @Published var editedMessage: Message?
    @Published var forwardMessage: Message?
    @Published var showSharePostVew: Bool = false



    
    @Published var imagePickerViewModels: [String: ImagePickerViewModel] = [:]
    @Published var completedUploadingSteps: [String: CGFloat] = [:]
    private var childrenCancellables: [String: AnyCancellable] = [:]

    //@Published var imagePickerViewModels: ImagePickerViewModel?
    //@Published var completedUploadingSteps: CGFloat = -1
    @Published var uploadAllSteps: [String: CGFloat] = [:]
    @Published var showImagePicker: Bool = false
    
    //var imagePickerViewModel: ImagePickerViewModel?
        
    
 private var cancelables = Set<AnyCancellable>()
 
 
     func subscribeTocompletedUploadingSteps(id: String) {
         imagePickerViewModels[id]!.$completedUploadingSteps
             .sink { [weak self] newValue in
                 // Handle changes in ImagePickerViewModel
                 DispatchQueue.main.async {
                     
                         self?.completedUploadingSteps[id] = newValue
                    // print("completedUploadingSteps updated inside subscribe chat view model: \(self?.completedUploadingSteps)")

                         
                     
                 }
             }
             .store(in: &cancelables)
     }
    
    

    
    init(currentUser: DBUser, otherUser: DBUser, listing: Listing? = nil){
        self.currentUser = currentUser
        self.otherUser = otherUser
        self.listing = listing
        
        Task{
            fetchMessages()
        }
    }
    

    
    //MARK: Fetch and load functionalities
   

    func fetchMessages() {
        cancellable?.cancel()
      
        cancellable = MessageManager.shared.fetchMessages(currentUser: currentUser, otherUid: otherUser.id, count: fetchCount)
            .sink { completion in
                
            } receiveValue: { [weak self] newMessages in
                self?.messages = newMessages
               
               
            }
    }
    
    func editMesssage() async throws {
        
        if var existingMessage = editedMessage{
            
           
            if existingMessage.text != messageContent{
                existingMessage.isEdited = true
            }
            existingMessage.text = messageContent
            messageContent = ""
            editedMessage = nil
            try await MessageManager.shared.sendMessage(message: existingMessage, otherUser: otherUser)
            try await MessageManager.shared.markDeliver(message: existingMessage)
           
            
        }
    }
    

    func sendMesssage(id: String? = nil) async throws {
        
        print("listing inside chatBoxViewModel: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \( listing)")

        
        var messageId : String = UUID().uuidString
        var urls : [UploadedUrls] = []
        var aspectRatio: CGFloat = 1.0
        if let id = id{ messageId = id}
        
        
        var newMessage = Message(id: messageId, ownerId: currentUser.id, recipientId: otherUser.id, text: messageContent, caption: caption, ownerPhotoUrl: currentUser.photoUrl, ownerUsername: currentUser.username ?? "no name", recipientPhotoUrl: otherUser.photoUrl, recipientUsername: otherUser.username ?? "no name")
        
        if let repliedMessage = repliedMessage{
            newMessage.replyToMessageId = repliedMessage.id
            if let url = repliedMessage.thumbnailUrls?.first{
                newMessage.repliedImageUrl = url
            }
            newMessage.repliedText = repliedMessage.text
            newMessage.isReply = true
            newMessage.replyMessageOwnerId = repliedMessage.ownerId
            
            if repliedMessage.isPost{
                
                
                newMessage.sharedPostId =  repliedMessage.sharedPostId
                newMessage.isReplyToPost = true
                newMessage.sharedPostThumbnail = repliedMessage.sharedPostThumbnail
                newMessage.sharedPostIsVideo = repliedMessage.sharedPostIsVideo
                newMessage.sharedPostAspectRatio = repliedMessage.sharedPostAspectRatio
                newMessage.sharedPostOwnerUsername = repliedMessage.sharedPostOwnerUsername
                newMessage.sharedPostOwnerPhotoUrl =  repliedMessage.sharedPostOwnerPhotoUrl
                newMessage.sharedPostCaption = repliedMessage.sharedPostCaption
            }
            
          else  if repliedMessage.isListing{
                
                
                newMessage.sharedPostId =  repliedMessage.sharedPostId
                newMessage.isReplyToListing = true
                newMessage.sharedPostThumbnail = repliedMessage.sharedPostThumbnail
                newMessage.sharedPostIsVideo = repliedMessage.sharedPostIsVideo
                newMessage.sharedPostAspectRatio = repliedMessage.sharedPostAspectRatio
                newMessage.sharedPostOwnerUsername = repliedMessage.sharedPostOwnerUsername
                newMessage.sharedPostOwnerPhotoUrl =  repliedMessage.sharedPostOwnerPhotoUrl
                newMessage.sharedPostCaption = repliedMessage.sharedPostCaption
            }
            
            
            
        }
        repliedMessage = nil
        
        
        if let listing = listing{
            
            print("message is about listing inside chatViewModel >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            
            newMessage.isAboutListing = true
            newMessage.sharedPostId = listing.id
            newMessage.sharedPostThumbnail = listing.thumbnailUrls?.first
            newMessage.ListingId = listing.id
            if let url = listing.urls?.first, url.contains("Videos"){
                newMessage.sharedPostIsVideo = true
            }
            newMessage.sharedPostAspectRatio = listing.aspectRatio

            
        }
        
        
        
        do{
            if let id = id, let pickerViewModel = self.imagePickerViewModels[id], pickerViewModel.selectedAssets.count > 0{
                
                imagePickerViewModels[id]?.completedUploadingSteps = 0
                completedUploadingSteps[id] = 0
                try await pickerViewModel.cropImages()
                uploadAllSteps[id] = CGFloat(pickerViewModel.selectedAssets.count) * 2 + 1
                newMessage.croppedImage = pickerViewModel.croppedImages
                messages.insert(newMessage, at: 0)
                showImagePicker = false
                urls = try await pickerViewModel.uploadMessage()
                aspectRatio = pickerViewModel.aspectRatioGeneral
                
            }else{
                
            }
            
            let (urls, imageUrls, thumbnailUrls) = getUrls(urls: urls)
            
            newMessage.urls = urls
            newMessage.imageUrls = imageUrls
            newMessage.thumbnailUrls = thumbnailUrls
            newMessage.aspectRatio = aspectRatio

            newMessage.time = Timestamp()
            try await MessageManager.shared.sendMessage(message: newMessage, otherUser: otherUser)
            try await MessageManager.shared.markDeliver(message: newMessage)
            print("message successfuly sent to firestore")
            if let id = id {
                imagePickerViewModels[id]?.completedUploadingSteps += 1
                completedUploadingSteps[id] = -1
                imagePickerViewModels[id] = nil
            }
            
            
        } catch{
            if let id = id {
                completedUploadingSteps[id] = -1
                imagePickerViewModels[id] = nil
            }
        }
        
    }
    
    
    func getUrls(urls: [UploadedUrls]) -> ([String], [String], [String]){
        
        var outputUrls : ([String], [String], [String]) = ([], [], [])
        for urlObject in urls{
            if let videoUrl = urlObject.videoUrl {
                outputUrls.0.append(videoUrl)
                outputUrls.1.append(urlObject.imageUrl)
                outputUrls.2.append(urlObject.thumbnailUrl)


            } else{
                outputUrls.0.append(urlObject.imageUrl)
                outputUrls.1.append(urlObject.imageUrl)
                outputUrls.2.append(urlObject.thumbnailUrl)
            }
        }
        
        return outputUrls
    
    }
    
    
   

    
    
    func markSeen(message: Message) async throws {
        try await MessageManager.shared.markSeen(message: message)
    }
    
    func react(message: Message, emoji: String)  async throws {
        
        try await MessageManager.shared.addEmoji(message: message, uid: currentUser.id, emoji: emoji)
    }
    
    func edit(message: Message) async throws {
        
        try await MessageManager.shared.edit(message: message, newText: messageContent)
    }
    
    func delete(message: Message) async throws{
        try await MessageManager.shared.delete(message: message)
    }
    
    func hide(message: Message) async throws{
        try await MessageManager.shared.hide(message: message)
    }
    
    func unHide(message: Message) async throws{
        try await MessageManager.shared.unHide(message: message)
    }
    
    
    
    
    func fetchPost(message: Message) async throws -> Post?{
        
       
        
        if let postId = message.sharedPostId{
            do{
                var fetchedPost = try await PostManager.shared.getPost(postId: postId)
                fetchedPost.user = try await UserManager.shared.getUser(userId: fetchedPost.ownerUid)
                return fetchedPost
                
            } catch{
                return nil
            }
            
            
        }else{
            return nil
        }
    }
    
    
    
    
    func fetchListing(message: Message) async throws -> Listing?{
        
       
        
        if let listingId = message.sharedPostId{
            do{
               
                
                var fetchedListing = try await ListingManager.shared.getListing(listingId: listingId)
                fetchedListing.user = try await UserManager.shared.getUser(userId: fetchedListing.ownerUid)
                return fetchedListing
                
            } catch{
                return nil
            }
            
            
        }else{
            return nil
        }
    }
        
        
    
    
}
