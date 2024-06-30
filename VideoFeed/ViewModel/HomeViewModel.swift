//
//  HomeViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/30/24.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel : ObservableObject{
    
    @Published var selection: Int = 0
    @Published var previousSelection: Int = 0
    @Published var completedUploadingSteps: CGFloat = -1
    @Published var numberOfSelectedAssets: CGFloat = 0
    @Published var uploadedPostId: String?
    @Published var unreadChats: [String: UnreadChat] = [:]

    let user: DBUser
    var MessageviewModel: MessageViewModel
    var feedViewModel: FeedViewModel
    var listingViewModel : ListingViewModel
    var mapViewModel : MapViewModel
    
    var imagePickerViewModel: ImagePickerViewModel? {
           didSet {
               subscribenumberOfSelectedAssets()
               subscribeTocompletedUploadingSteps()
               subscribeUploadedPostId()
           }
       }
    private var cancelables = Set<AnyCancellable>()
    
    
    init(user: DBUser){
        self.user = user
        self.MessageviewModel = MessageViewModel(user: user)
        self.feedViewModel = FeedViewModel(user: user)
        self.listingViewModel = ListingViewModel(user: user)
        self.mapViewModel = MapViewModel(currentUser: user)
        subscribeToUnreadChats()
        
        
    }
    
    
    
    
    private func subscribeToUnreadChats() {
            MessageviewModel.$unreadChats
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel
                    DispatchQueue.main.async{
                        self?.unreadChats = newValue
                    }
                }
                .store(in: &cancelables)
        }
    
    
    private func subscribeTocompletedUploadingSteps() {
            imagePickerViewModel?.$completedUploadingSteps
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel
                    DispatchQueue.main.async{
                        self?.completedUploadingSteps = newValue
                    }
                }
                .store(in: &cancelables)
        }
    
    private func subscribenumberOfSelectedAssets() {
        imagePickerViewModel?.$numberOfSelectedItems
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel
                    DispatchQueue.main.async{
                        self?.numberOfSelectedAssets = newValue
                    }
                }
                .store(in: &cancelables)
        }
    
    
    private func subscribeUploadedPostId() {
        imagePickerViewModel?.$postId
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel
                    DispatchQueue.main.async{
                        self?.uploadedPostId = newValue
                    }
                }
                .store(in: &cancelables)
        }
    
  
}
