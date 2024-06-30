//
//  ListingviewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/11/24.
//

import Foundation
import FirebaseFirestore
import Combine

enum ListingSection{
    case explore
    case interest
    case active
    case expired
    case activeOtherUser
    case search
}

@MainActor
final class ListingViewModel: ObservableObject{
    
    @Published var listingExplore: [Listing] = []
    @Published var listingInterest: [Listing] = []
    @Published var listingActive: [Listing] = []
    @Published var listingActiveOtherUser: [Listing] = []
    @Published var listingExpired: [Listing] = []
    @Published var listingKeywords: [Listing] = []
    @Published var favoriteCategories: [String] = []
    @Published var completedUploadingSteps: CGFloat = -1
    @Published var uploadAllSteps: CGFloat = 1
    @Published var uploadedListingId: String?
    @Published var marketViewAppeared: Bool = false
    @Published var searchText: String = ""
    
  
    
    @Published var user: DBUser
    
    var lastDocumentExplore: DocumentSnapshot?
    var lastDocumentInterest: DocumentSnapshot?
    var lastDocumentActive: DocumentSnapshot?
    var lastDocumentExpired: DocumentSnapshot?
    var lastDocumentActiveOtherUser: DocumentSnapshot?
    var lastDocumentKeywords: DocumentSnapshot?

    
    var createListingViewModel: CreateListingViewModel?{
        didSet {
            
            subscribeTocompletedUploadingSteps()
            subscribeTouploadAllSteps()
            subscribeTouploadedListingId()}
       }
    
    
    

    private var cancelables = Set<AnyCancellable>()
    
    
    
    
    private func observeSearchString() {
            $searchText
                .debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .sink { [weak self] newValue in
                    if newValue.count >= 3{
                        
                        Task {
                            print("market keywords search: >>>>>>>>>>>>>>>>> \(self?.searchText)")
                            self?.listingKeywords = []
                            self?.lastDocumentKeywords = nil
                            try await self?.getListingsTimeAndKeywords()
                        }
                    }else{
                        self?.listingKeywords = []
                        self?.lastDocumentKeywords = nil

                    }
                }
                .store(in: &cancelables)
        }
    
    
    private func subscribeTocompletedUploadingSteps() {
        createListingViewModel?.$completedUploadingSteps
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel
                    

                    DispatchQueue.main.async {
                        
                            self?.completedUploadingSteps = newValue
                            
                        
                    }
                }
                .store(in: &cancelables)
        }
    
    
    
    private func subscribeTouploadAllSteps() {
        createListingViewModel?.$uploadAllSteps
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel
                    

                    DispatchQueue.main.async {
                        
                            self?.uploadAllSteps = newValue
                            
                        
                    }
                }
                .store(in: &cancelables)
        }
    
    
    private func subscribeTouploadedListingId() {
        createListingViewModel?.$uploadedListingId
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel
                    

                    DispatchQueue.main.async {
                        
                            self?.uploadedListingId = newValue
                            
                        
                    }
                }
                .store(in: &cancelables)
        }
    


    init(user: DBUser){
        self.user = user
        self.favoriteCategories = user.listingCategory
        self.observeSearchString()
    
    }

    func fetchUserActiveListing() async throws{
        if listingActive.count > 0 && lastDocumentActive == nil{ return}
        
        let fetchResult = try await ListingManager.shared.getListingsActiveByTimeAndUid(count: 10, uid: user.id, lastDocument: lastDocumentActive)
        lastDocumentActive = fetchResult.lastDocument
        try await fetchAndsetListingOwner(FetchedListings: fetchResult.output, section: .active)
    }
    
    func fetchUserExpiredListing() async throws{
        if listingExpired.count > 0 && lastDocumentExpired == nil{ return}
        
        let fetchResult = try await ListingManager.shared.getListingsExpiredByTimeAndUid(count: 10, uid: user.id, lastDocument: lastDocumentExpired)
        lastDocumentExpired = fetchResult.lastDocument
        
        try await fetchAndsetListingOwner(FetchedListings: fetchResult.output, section: .expired)
    }
    
    func fetchUserExploreListing(restricted: [String]? = nil) async throws{
        if listingExplore.count > 0 && lastDocumentExplore == nil{ return}
        
        
        
        let fetchResult = try await ListingManager.shared.getListingsByTime(count: 20 , lastDocument: lastDocumentExplore)
        lastDocumentExplore = fetchResult.lastDocument
        try await fetchAndsetListingOwner(FetchedListings: fetchResult.output, section: .explore)
    }
    

    
    func addFavoriteCategory(category: String) async throws {
        
        try await UserManager.shared.addListingCategory(uid: user.id, category: category)
    }
    
    func removeFavoriteCategory(category: String) async throws {
        
        try await UserManager.shared.removeListingCategory(uid: user.id, category: category)
    }
    
    
    func fetchUserInterestListing(restricted: [String]? = nil) async throws{
        if listingInterest.count > 0 && lastDocumentInterest == nil{ return}
        
        
        
        let fetchResult = try await ListingManager.shared.getListingsByTimeAndCategory(count: 20, categories: favoriteCategories, lastDocument: lastDocumentInterest)
        lastDocumentInterest = fetchResult.lastDocument
        try await fetchAndsetListingOwner(FetchedListings: fetchResult.output, section: .interest)
    }
    
    
    func fetchAndsetListingOwner(FetchedListings: [Listing], section: ListingSection) async throws{
        
        for var listing in FetchedListings{
            do{
                try await listing.setUserOwner()
                

                    switch section{
                    case .active:
                        
                        if listing.user != nil{
                            
                            listingActive.append(listing)
                        }
                        
                    case .explore:
                        
                        if let listingOwner = listing.user , !user.hiddenPostIds.contains(listing.id) , !user.blockedIds.contains(listingOwner.id) , !user.mutedIds.contains(listingOwner.id), !listingOwner.blockedIds.contains(user.id), listingOwner.id != user.id{
                            
                            
                            listingExplore.append(listing)
                        }

                    case .interest:
                        
                        if let listingOwner = listing.user , !user.hiddenPostIds.contains(listing.id) , !user.blockedIds.contains(listingOwner.id) , !user.mutedIds.contains(listingOwner.id), !listingOwner.blockedIds.contains(user.id), listingOwner.id != user.id{
                            
                            
                            listingInterest.append(listing)
                        }

                    case .expired:
                        
                        if listing.user != nil{
                            listingExpired.append(listing)
                        }
                        
                    case .activeOtherUser:
                        
                        if let listingOwner = listing.user  , !user.blockedIds.contains(listingOwner.id) ,  !listingOwner.blockedIds.contains(user.id){
                            
                            listingActiveOtherUser.append(listing)
                        }

                    case .search:
                        
                        if let listingOwner = listing.user , !user.hiddenPostIds.contains(listing.id) , !user.blockedIds.contains(listingOwner.id) , !listingOwner.blockedIds.contains(user.id){
                            
                            
                            listingKeywords.append(listing)
                        }
                    }
                
            } catch{
                continue
            }
        }
    }
    
    func fetchListingAddToActive(listingId: String) async throws {
       
            var listing = try await ListingManager.shared.getListingById(listingId: listingId)
            try await listing.setUserOwner()
            listingActive.insert(listing, at: 0)
    }
    
    
    func fetchOtherUserActiveListing(uid: String) async throws{
        if listingActiveOtherUser.count > 0 && lastDocumentActiveOtherUser == nil{ return}
        
        let fetchResult = try await ListingManager.shared.getListingsActiveByTimeAndUid(count: 10, uid: uid, lastDocument: lastDocumentActiveOtherUser)
        lastDocumentActiveOtherUser = fetchResult.lastDocument
        try await fetchAndsetListingOwner(FetchedListings: fetchResult.output, section: .activeOtherUser)
        print("fetch called inside viewModel  >>>>>>>>>>>>")
    }
    
    
    func getListingsTimeAndKeywords() async throws {
        if listingKeywords.count > 0 && lastDocumentKeywords == nil{ return}
        do{
            let keywords = sentenceToWords(sentence: searchText)
            let fetchResult = try await ListingManager.shared.getListingsActiveByTimeAndKeywords(count: 20, keywords: keywords, lastDocument: lastDocumentKeywords)
            lastDocumentKeywords = fetchResult.lastDocument
            try await fetchAndsetListingOwner(FetchedListings: fetchResult.output, section: .search)
            print("search listing result count for keywords: \(keywords)>>>>>>>>>>>>>>>>>\(fetchResult.output.count)")
        }
    }
    
    func sentenceToWords(sentence: String) -> [String] {
        let wordsWithPunctuation = sentence.components(separatedBy: " ")
        let words = wordsWithPunctuation.map { word in
            word.trimmingCharacters(in: .punctuationCharacters).lowercased()
        }
        .filter { $0.count >= 3 } // Filter out words with fewer than 4 characters

        // Remove duplicates by converting to a Set and then back to an Array
        let uniqueWords = Array(Set(words.filter { !$0.isEmpty }))
        
        return uniqueWords
    }

    
}
