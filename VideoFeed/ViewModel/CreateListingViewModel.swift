//
//  CreateListingViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/10/24.
//

import Foundation
import FirebaseFirestore
import MapKit
import Combine
import SwiftUI
import GeohashKit



@MainActor
final class CreateListingViewModel: ObservableObject{
    
    
    @Published var selectedCategory: String = ListingCategory.sale.rawValue
    @Published var title: String = ""
    @Published  var selectedDate = Date()
    @Published  var endDate = Date()
    @Published  var selectedPrice: Double = 50
    @Published var placeSearchResults: [MKMapItem] = []
    @Published var description: String = ""
    @Published var originPlace: (String, String)?
    @Published var destinationPlace: (String, String)?
    @Published var expireDate = Date()
    @Published var allowMessage: Bool = true
    @Published var isPublic: Bool = true
    @Published var completedUploadingSteps: CGFloat = -1
    @Published var uploadAllSteps: CGFloat = 1
    @Published var uploadedListingId: String?
    @Published var originLocation: GeoPoint?
    @Published var destinationLocation: GeoPoint?
    @Published var originGeoHash5 : String?
    @Published var originGeoHash6 : String?
    @Published var originGeoHash7 : String?
    @Published var destinationGeoHash5 : String?
    @Published var destinationGeoHash6 : String?
    @Published var destinationGeoHash7 : String?
    @Published var showPlaceResults: Bool = false
    @Published var placeType: PlaceType = .origin
    @Published  var originSearchQuery: String = ""
    @Published  var destinationSearchQuery: String = ""
    @Published var selectedAssets: [AssetModel] = []
    
    @Published var activeNextButton: Bool = false
    @Published var showTitleError: Bool = false
    @Published var showOriginError: Bool = false
    @Published var showDestinationError: Bool = false
    @Published var showDescriptionError: Bool = false
    @Published var showImageError: Bool = false
    @Published var step: Double = 5
    @Published var range: ClosedRange<Double> = 5...200
    @Published  var settingsDetent = PresentationDetent.medium
    @Published var showImagePicker: Bool = false
   
    var user: DBUser
    
    var imagePickerViewModel: ImagePickerViewModel?{
           didSet {
               subscribeTocompletedUploadingSteps()
               subscribeToselectedAssets()
           }
       }
    
    
    init(user: DBUser){
        self.user = user
    }
    
    private var cancelables = Set<AnyCancellable>()
    
    
    private func subscribeTocompletedUploadingSteps() {
            imagePickerViewModel?.$completedUploadingSteps
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel

                    DispatchQueue.main.async {
                        withAnimation {
                            self?.completedUploadingSteps = newValue
                            
                        }
                    }
                }
                .store(in: &cancelables)
        }
    
    
    private func subscribeToselectedAssets() {
            imagePickerViewModel?.$selectedAssets
                .sink { [weak self] newValue in
                    // Handle changes in ImagePickerViewModel

                    DispatchQueue.main.async {
                        withAnimation {
                            self?.selectedAssets = newValue
                            
                        }
                    }
                }
                .store(in: &cancelables)
        }

    
    
    
    func shareListing(formType: ListingFormTypeEnum, existingListing: Listing? = nil) async throws -> Listing {
        let listingId = UUID().uuidString
        var urls : [UploadedUrls] = []
        var aspectRatio: CGFloat = 1.0
        let keywords = generateKeywords()
        do{
            if let pickerViewModel = self.imagePickerViewModel, pickerViewModel.selectedAssets.count > 0{
                uploadAllSteps = CGFloat(pickerViewModel.selectedAssets.count) * 2 + 1
                urls = try await pickerViewModel.uploadListing()
                aspectRatio = pickerViewModel.aspectRatioGeneral
                
            }else{
                uploadAllSteps = 1
            }
            let (urls, imageUrls, thumbnailUrls) = getUrls(urls: urls)
            let validUntil: Timestamp = selectedCategory == ListingCategory.ride.rawValue ? Timestamp(date: selectedDate) : getExpiredate()
            var listing = Listing(id: listingId, ownerUid: user.id, title: title, category: selectedCategory, validUntil: validUntil, isPublic: isPublic, allowMessage: allowMessage, desiredTime: Timestamp(date:selectedDate), endTime: Timestamp(date:endDate), price: selectedPrice, urls: urls, imageUrls: imageUrls, thumbnailUrls: thumbnailUrls, description: description, aspectRatio: aspectRatio, originPlaceName: originPlace?.0, originPlaceAddress: originPlace?.1, destinationPlaceName: destinationPlace?.0, destinationPlaceAdress: destinationPlace?.1, originLocation: originLocation, destinationLocation: destinationLocation, originGeoHash5: originGeoHash5, originGeoHash6: originGeoHash6, originGeoHash7: originGeoHash7, destinationGeoHash5: destinationGeoHash5, destinationGeoHash6: destinationGeoHash6, destinationGeoHash7: destinationGeoHash7, ownerUsername: user.username ?? "", ownerPhotoUrl: user.photoUrl, keywords: keywords)
            
            
            switch formType {
            case .create:
                
                try await ListingManager.shared.uploadListing(listing: listing)
                try await UserManager.shared.updateUserListing(uid: user.id, listingId: listingId, time: validUntil)
                print("Listing successfully saved into firestore")
                completedUploadingSteps += 1
                uploadedListingId = listingId
                return listing
                
            case .edit:
                listing.isEdited = true
                if let existingListing = existingListing{
                    listing.id = existingListing.id
                    listing.time = existingListing.time
                    listing.urls = existingListing.urls
                    listing.thumbnailUrls = existingListing.thumbnailUrls
                    listing.imageUrls = existingListing.imageUrls
                    listing.aspectRatio = existingListing.aspectRatio
                }
                try await ListingManager.shared.editListing(listing: listing)
                return listing

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
    
    func getExpiredate() -> Timestamp{
        
        var dateComponents = DateComponents()
        dateComponents.day = 2
        let twoDaysFromNow = Calendar.current.date(byAdding: dateComponents, to: Date())!
        if twoDaysFromNow > expireDate{
            
            var dateComponents = DateComponents()
            dateComponents.year = 1
            let oneYearFromNow = Calendar.current.date(byAdding: dateComponents, to: Date())!
            let oneYearTimestamp = Timestamp(date: oneYearFromNow)
            return oneYearTimestamp
        } else{
            
            return Timestamp(date: expireDate)
        }
    }
    
    
    func adjustDate(){
        
        if selectedCategory == ListingCategory.event.rawValue{
            if let suggestedDate = Calendar.current.date(byAdding: .hour, value: 2, to: selectedDate){
                endDate = suggestedDate
            }else{
                endDate = selectedDate
            }
        }else{
            if let suggestedDate = Calendar.current.date(byAdding: .month, value: 3, to: selectedDate){
                endDate = suggestedDate
            }else{
                endDate = selectedDate
            }
        }
    }
    
    
    
    func getLocationAndGeohash(mapItem: MKMapItem) -> (GeoPoint, String, String, String)?{
        
        
        if let location = mapItem.placemark.location?.coordinate{

            let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
            
            if let geoHash = Geohash(coordinates: (location.latitude, location.longitude), precision: 12)?.geohash{
              
                
                return(geoPoint, String(geoHash.prefix(5)), String(geoHash.prefix(6)), String(geoHash.prefix(7)))
          
            }
        }
        
        return nil
    }
    
    
    
    
    func validateOriginPlace() -> Bool {
        if originPlace == nil {
            showOriginError = true
        }
        
        return originPlace != nil
    }
    
    
    func validateDestinationPlace() -> Bool {
        
        if destinationPlace == nil {
            showDestinationError = true
        }
        return  destinationPlace != nil
    }

    func validateTitle() -> Bool {
        if title.count < 1 {
            showTitleError = true
        }
        return title.count > 0
    }

    func validateDescription() -> Bool {
        if description.count < 1 {
            showDescriptionError = true
        }
        return description.count > 0
    }

    func validateImages() -> Bool {
        if imagePickerViewModel == nil || imagePickerViewModel?.selectedAssets.isEmpty == true {
            showImageError = true
        }
        return imagePickerViewModel?.selectedAssets.isEmpty == false
    }
    
    
    func resetErrorDisplay(){
        showImageError = false
        showTitleError = false
        showOriginError = false
        showDestinationError = false
        showDescriptionError = false
        
    }
    
    func resetLocations(){
        
        originLocation = nil
        destinationLocation = nil
        originGeoHash5 = nil
        originGeoHash6 = nil
        originGeoHash7 = nil
        destinationGeoHash5 = nil
        destinationGeoHash6 = nil
        destinationGeoHash7 = nil
        originPlace = nil
        destinationPlace = nil
        placeSearchResults = []

    }
    
    func resetImages(){
        imagePickerViewModel?.selectedAssets = []
    }
    
    func resetTitleAndDescription(){
        title = ""
        description = ""
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
    
    func generateKeywords() -> [String] {
        
        var keywords: [String] = []
        
        if let username = user.username{
            keywords.append(username.lowercased())
        }
        if let firstName = user.firstName{
            keywords.append(firstName.lowercased())
        }
        if let lastName = user.lastName{
            keywords.append(lastName.lowercased())
        }
        keywords.append(selectedCategory.lowercased())
        keywords.append(contentsOf: sentenceToWords(sentence: title))
        keywords.append(contentsOf: sentenceToWords(sentence: description))
        if let originPlace = originPlace{
            keywords.append(contentsOf: sentenceToWords(sentence: originPlace.0))
        }
        if let destinationPlace = destinationPlace{
            keywords.append(contentsOf: sentenceToWords(sentence: destinationPlace.0))
        }
        
        return keywords

    }
    
    
   
}
