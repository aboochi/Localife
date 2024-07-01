//
//  ImagePickerViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/22/24.
//

import SwiftUI
import PhotosUI
import Combine
import AVFoundation




enum SharePlatform{
    case post
    case story
}

struct UploadedUrls{
    var imageUrl: String
    var thumbnailUrl: String
    var videoUrl: String?
    
    init(imageUrl: String, thumbnailUrl: String, videoUrl: String? = nil) {
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.videoUrl = videoUrl
    }
}

@MainActor
final class ImagePickerViewModel : ObservableObject{
    
    @Published var fetchedAssets: [AssetModel] = []
    @Published var selectedAssets: [AssetModel] = []
    @Published var permissionAlertVisible: Bool = false
    @Published var currentPage: Int = 0
    let pageSize: Int = 50 // Number of assets per page
    let maxWidth = UIScreen.main.bounds.width * 0.95
    let maxHeight = UIScreen.main.bounds.height * 0.5
    @Published var assetCollections: [PHAssetCollection] = []
    @Published var selectedAssetCollection: PHAssetCollection? = nil
    @Published var aspectRatioGeneral: CGFloat = 1
    @Published var frameSize: CGSize = CGSize(width: 200, height: 200)
    @Published var displayIndex: Int = 0
    @Published var setToFixedAspectRatio: Bool = false
    @Published var dictatedAspectRatio: CGFloat = 1
    @Published var choiceLimit: Int = 10
    @Published var filter: PHAssetMediaType?
    @Published var completedUploadingSteps: CGFloat = -1
    @Published var numberOfSelectedItems: CGFloat = 0
    @Published var postId: String?
    @Published var mode : SharePlatform = .post
    @Published var croppedImages: [UIImage] = []
    @Published var caption: String = ""

    
    

    
    init(){
      
        fetchAssetCollections()
        requestPermission()
        
      
    }
    
    
    
    func setFrameSize(){
        var frameWidth: CGFloat
        var frameHeight: CGFloat

        if aspectRatioGeneral > 1 {
            frameWidth = min(maxWidth, maxHeight * aspectRatioGeneral)
            frameHeight = frameWidth / aspectRatioGeneral
        } else {
            frameHeight = min(maxHeight, maxWidth / aspectRatioGeneral)
            frameWidth = frameHeight * aspectRatioGeneral
        }

        frameSize = CGSize(width: frameWidth, height: frameHeight)
    }
    
    
    func checkPermission(){
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted {
            requestPermission()
        } else{
            
        }
        print("status:  >>>>>>>>>>>>>>>>>>>>>> \(status)")
    }
    
    func requestPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            print("permission request  \(status)")
            
            switch status{
                
            case .notDetermined:
                break
            case .restricted:
                DispatchQueue.main.async{
                    self.permissionAlertVisible = true
                }
            case .denied:
                DispatchQueue.main.async{
                    self.permissionAlertVisible = true
                }
            case .authorized:
                DispatchQueue.main.async{
                    self.fetchImages()
                }
            case .limited:
                DispatchQueue.main.async{
                    self.fetchImages()
                }
            @unknown default:
                break
            }
            
            }
        }
    
    
    func fetchImages() {
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        let mediaTypes = [PHAssetMediaType.image, PHAssetMediaType.video]
        options.predicate = NSPredicate(format: "mediaType IN %@", mediaTypes.map { $0.rawValue })
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let startIndex = currentPage * pageSize
        let fetchResult: PHFetchResult<PHAsset>
        
        if let collection = selectedAssetCollection {
            fetchResult = PHAsset.fetchAssets(in: collection, options: options)
        } else {
            fetchResult = PHAsset.fetchAssets(with: options)
        }
        // Adjust endIndex based on actual count of assets
        let endIndex = min((currentPage + 1) * pageSize - 1, fetchResult.count - 1)
        // Ensure startIndex is within bounds
        guard startIndex < fetchResult.count else { return }
        // Ensure endIndex is not negative
        guard endIndex >= 0 else { return }
        
        let fetchRange = NSRange(location: startIndex, length: endIndex - startIndex + 1)

        for index in fetchRange.location..<min(fetchRange.location + fetchRange.length, fetchResult.count) {
            let asset = fetchResult.object(at: index)
            
            if let filter = filter, asset.mediaType == filter { continue }
            
                var assetItem = AssetModel(asset: asset, thumbnail: nil)
                
                if index == 0 {
                    let aspectRatio = CGFloat(assetItem.asset.pixelWidth) / CGFloat(assetItem.asset.pixelHeight)
                    assetItem.aspectRatio = aspectRatio
                    assetItem.assetIndex = selectedAssets.count
                    selectedAssets.append(assetItem)
                    if !setToFixedAspectRatio{
                        let mediaType =  assetItem.asset.mediaType
                        aspectRatioGeneral = (mediaType == .video) ? max(aspectRatio, 0.5625) : max(aspectRatio, 0.75)
                    } else{
                        aspectRatioGeneral = dictatedAspectRatio
                    }
                    setFrameSize()
                    displayIndex = 0
                    
                }
                
                fetchedAssets.append(assetItem)
            
        }
    }

    

    // Function to fetch asset collections
    func fetchAssetCollections()  {
        

        // Fetch smart albums
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects { assetCollection, _, _ in
            self.assetCollections.append(assetCollection)
        }

        // Fetch user albums
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        userAlbums.enumerateObjects { assetCollection, _, _ in
            self.assetCollections.append(assetCollection)
        }

        
    }
    
    func loadNextPage() {
            currentPage += 1
            fetchImages()
        }
    
    func loadNextPage(assetItem: AssetModel){
        if let lastImage = fetchedAssets.last, assetItem.id == lastImage.id {
            loadNextPage()
        }
    }
    
    func loadthumbnail(asset: PHAsset, completion: @escaping (UIImage?) -> ()){
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic // Use high-quality format for initial display
        requestOptions.resizeMode = .exact
        
        let manager = PHCachingImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { image, _ in
            completion(image)
        }
    }
    
    func loadthumbnail(assetItem: AssetModel){
        let asset = assetItem.asset
        let id = assetItem.id
        guard let index = self.selectedAssets.firstIndex(where: { $0.id == id}) else { return  }

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic // Use high-quality format for initial display
        requestOptions.resizeMode = .exact
        
        let manager = PHCachingImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { image, _ in
            
            self.selectedAssets[index].thumbnail = image

        }
    }
    
    func loadthumbnail(assetItemBinding: Binding<AssetModel>){
        let asset = assetItemBinding.asset
        let id = assetItemBinding.id
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic // Use high-quality format for initial display
        requestOptions.resizeMode = .exact
        
        let manager = PHCachingImageManager.default()
        manager.requestImage(for: asset.wrappedValue, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { image, _ in
            
            assetItemBinding.wrappedValue.thumbnail = image

        }
    }
    
    
    func loadImage(asset: PHAsset, completion: @escaping (UIImage?) -> ()){
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat // Use high-quality format for initial display
        requestOptions.resizeMode = .exact
        
        let manager = PHCachingImageManager.default()
        manager.requestImage(for: asset, targetSize: .init(), contentMode: .default, options: requestOptions) { image, _ in
            completion(image)
        }
    }
    
    func loadImage(assetItem: AssetModel){
        let id = assetItem.id
        guard let index = self.selectedAssets.firstIndex(where: { $0.id == id}) else { return  }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat // Use high-quality format for initial display
        requestOptions.resizeMode = .exact
        
        let manager = PHCachingImageManager.default()
        manager.requestImage(for: assetItem.asset, targetSize: .init(), contentMode: .default, options: requestOptions) { image, _ in
            
            self.selectedAssets[index].image = image
        }
    }
    
    func requestImage(for asset: PHAsset) async throws -> UIImage {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat // Use high-quality format for initial display
        requestOptions.resizeMode = .exact
        let manager = PHCachingImageManager.default()
        return try await withCheckedThrowingContinuation { continuation in
            manager.requestImage(for: asset, targetSize: .init(), contentMode: .default, options: requestOptions) { image, _ in
                if let image = image {
                    print("Video thumbnail successfully loaded")
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: URLError(URLError.badURL))
                }
            }
        }
    }

    func loadThumbnail(assetItem: AssetModel) async throws -> UIImage{
    
        return try await requestImage(for: assetItem.asset)
 
    }

    func loadVideo(asset: PHAsset, completion: @escaping (AVPlayer?) -> ()){
        
        let manager = PHImageManager.default()
        
       
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = .current
        requestOptions.deliveryMode = .automatic
        manager.requestPlayerItem(forVideo: asset, options: requestOptions) { playerItem, _ in
            
            if let playerItem = playerItem {
                let player = AVPlayer(playerItem: playerItem)
                player.actionAtItemEnd = .none
                completion(player)
            }
        }
    }
    
    func loadVideo(assetItem: AssetModel){
        let id = assetItem.id
        guard let index = self.selectedAssets.firstIndex(where: { $0.id == id}) else { return  }

        let manager = PHImageManager.default()
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = .current
        requestOptions.deliveryMode = .automatic
        manager.requestPlayerItem(forVideo: assetItem.asset, options: requestOptions) { playerItem, _ in
            
            if let playerItem = playerItem {
                print("playerItem.status inside image picker: \(playerItem.status)")

                let player = AVPlayer(playerItem: playerItem)
                player.actionAtItemEnd = .none
                self.selectedAssets[index].player = player
            }
        }
    }
    
    func getVideoDuration(for asset: PHAsset) -> String? {
        // Check if the asset is a video
        guard asset.mediaType == .video else {
            return nil
        }

        // Retrieve the video duration in seconds
        let duration = asset.duration

        // Convert the duration to the hour:minute:second format
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        if duration >= 3600 { // If duration is one hour or more
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }

        if let formattedDuration = formatter.string(from: duration) {
            return formattedDuration
        }else {
            return nil
        }
    }
    
    
    func setInitialScale(id: String){
        guard let index = self.selectedAssets.firstIndex(where: { $0.id == id}) else { return  }
        self.selectedAssets[index].setIntialScale(aspectRatioGeneral: aspectRatioGeneral)
        
    }
    
    func setInitialScale(){
        for (index, itemAsset) in selectedAssets.enumerated(){
            
            selectedAssets[index].setIntialScale(aspectRatioGeneral: aspectRatioGeneral)
        }
    }
    
    
    
    func setOffset(id: String, accumulatedOffset: CGSize){
        guard let index = self.selectedAssets.firstIndex(where: { $0.id == id}) else { return  }
        self.selectedAssets[index].setOffset(accumulatedOffset)
    }
    
    
    func setAssetScale(id: String, scale: CGFloat){
        guard let index = self.selectedAssets.firstIndex(where: { $0.id == id}) else { return  }
       
            self.selectedAssets[index].scale = scale
        
    }
    
    func correctOffset(){
        for (index, _) in selectedAssets.enumerated(){
            correctOffset(index: index)
        }
    }
    
    
    func correctOffset(id: String){
        guard let index = self.selectedAssets.firstIndex(where: { $0.id == id}) else { return  }
        correctOffset(index: index)
        
    }
    
    func correctOffset(index: Int){
        
        var calculatedAspectRatio = 1.0
        if let aspectRatio = selectedAssets[index].aspectRatio{
            calculatedAspectRatio = aspectRatio
        }else{
            calculatedAspectRatio = Double(selectedAssets[index].asset.pixelWidth) /  Double(selectedAssets[index].asset.pixelHeight)
        }
        let aspectScale = aspectRatioGeneral / calculatedAspectRatio
        let scale = selectedAssets[index].scale
        if aspectScale > 1 {
            
            let offsetLimitWidth = frameSize.width * (scale - 1) / 2
            let offsetLimitHeight = (((frameSize.width / calculatedAspectRatio * scale) - frameSize.height ) ) / 2
            
            withAnimation(.easeInOut) {
                correctOffsetWidth(index: index, offsetLimitWidth: offsetLimitWidth)
                correctOffsetHeight(index: index, offsetLimitHeight: offsetLimitHeight)
            }
            
        } else{
            
            let offsetLimitHeight = frameSize.height * (scale - 1) / 2
            let offsetLimitWidth = (((frameSize.height * calculatedAspectRatio) * scale - frameSize.width) ) / 2
            
            withAnimation(.easeInOut) {
                correctOffsetHeight(index: index, offsetLimitHeight: offsetLimitHeight)
                correctOffsetWidth(index: index, offsetLimitWidth: offsetLimitWidth)
            }
        }
    }
    
    func correctOffsetWidth(index: Int, offsetLimitWidth: CGFloat){
        
        if abs(selectedAssets[index].offset.width) > offsetLimitWidth {
            if selectedAssets[index].offset.width >= 0{
               
                    selectedAssets[index].offset.width = offsetLimitWidth
               
            } else {
               
                    selectedAssets[index].offset.width = -offsetLimitWidth
                
            }
        }
    }
    
    
    func correctOffsetHeight(index: Int, offsetLimitHeight: CGFloat){
        print(" selectedAssets[index].offset.width: \(selectedAssets[index].offset.width)")

        print(" selectedAssets[index].offset.height: \(selectedAssets[index].offset.height)")

        
        if abs(selectedAssets[index].offset.height) > offsetLimitHeight {
            if selectedAssets[index].offset.height > 0 {
              
                    selectedAssets[index].offset.height = offsetLimitHeight
                
            } else  {
               
                    selectedAssets[index].offset.height = -offsetLimitHeight
                
            }
        }
    }
    
    func setAspectRatioGeneral(index: Int){
        
        if !setToFixedAspectRatio{
            
            if selectedAssets.count > 0 && index == 0{
                if selectedAssets.count > 1 {
                    aspectRatioGeneral = max((selectedAssets.first?.aspectRatio)!, 0.75)
                } else{
                    let aspectRatio = (selectedAssets.first?.aspectRatio)!
                    let mediaType =  selectedAssets.first?.asset.mediaType
                    aspectRatioGeneral = (mediaType == .video) ? max(aspectRatio, 0.5625) : max(aspectRatio, 0.75)
                }
                setFrameSize()
                setInitialScale()
                correctOffset()
                
            } else if selectedAssets.count > 0 && index == 1{
                aspectRatioGeneral = (selectedAssets.first?.aspectRatio)!
                setFrameSize()
                setInitialScale()
                correctOffset()
            }
        }
    }
    
    func removeAsset(assetItem: AssetModel, index: Int){
        
       
            selectedAssets.remove(at: index)
            selectedAssets.enumerated().forEach { item in
                self.selectedAssets[item.offset].assetIndex = item.offset
            }
            
            setAspectRatioGeneral(index: index)
            
            displayIndex = selectedAssets.count - 1
        }
    
    func resetframeProperties(){
        if setToFixedAspectRatio {
            aspectRatioGeneral = dictatedAspectRatio
        } else {
            if selectedAssets.count > 1 {
                aspectRatioGeneral = max((selectedAssets.first?.aspectRatio)!, 0.75)
            } else if selectedAssets.count == 1{
                let maxRatio = selectedAssets.first!.asset.mediaType == .video ? 0.5625 : 0.75
                aspectRatioGeneral = max((selectedAssets.first?.aspectRatio)! , maxRatio)
            } else {
                aspectRatioGeneral = 1
            }
        
        }
        setFrameSize()
        setInitialScale()
        correctOffset()
    }

    
    func addAsset(assetItem: AssetModel){
        
        if choiceLimit > 1{
            
            if selectedAssets.count >= choiceLimit{ return }
            
            let aspectRatio = CGFloat(assetItem.asset.pixelWidth) / CGFloat(assetItem.asset.pixelHeight)
            
            var newAsset = assetItem
            let count = selectedAssets.count
            newAsset.aspectRatio = aspectRatio
            newAsset.assetIndex = count
            
            if !setToFixedAspectRatio {
                if count == 0 {
                    let maxRatio = newAsset.asset.mediaType == .video ? 0.5625 : 0.75
                    aspectRatioGeneral = max(maxRatio, aspectRatio)
                    setFrameSize()
                } else if aspectRatioGeneral < 0.75{
                    aspectRatioGeneral = 0.75
                    setFrameSize()
                    setInitialScale()
                    correctOffset()
                }
            } else {
                aspectRatioGeneral = dictatedAspectRatio
                setFrameSize()
                setInitialScale()
                correctOffset()
                
            }
            selectedAssets.append(newAsset)
            setInitialScale(id: assetItem.id)
            displayIndex = selectedAssets.count - 1
        } else if choiceLimit == 1{
            selectedAssets = [assetItem]
            displayIndex = 0
        }
    }
    
    func addOrRemoveAsset(assetItem: AssetModel){
        if let index = selectedAssets.firstIndex(where: {$0.id == assetItem.id}){
            
            removeAsset(assetItem: assetItem, index: index)
            
        } else {
            
            addAsset(assetItem: assetItem)
            
        }
    }
    
    func calculateCropRect(assetItem: AssetModel) -> (CGRect, CGFloat, CGFloat){
        
        let aspectRatio = assetItem.getAspectRatio()
        var offsetScale: CGFloat
        var framedImageWidth: CGFloat
        var framedImageHeight: CGFloat
        let imageWidth = CGFloat(assetItem.asset.pixelWidth)
        let imageHeight = CGFloat(assetItem.asset.pixelHeight)
        let scale = assetItem.scale
        let xOffset = assetItem.offset.width
        let yOffset = assetItem.offset.height

        if aspectRatioGeneral > aspectRatio{
            framedImageWidth = imageWidth
            framedImageHeight = imageWidth / aspectRatioGeneral
            
        } else {
            framedImageHeight = imageHeight
            framedImageWidth = imageHeight * aspectRatioGeneral
        }
        
        offsetScale = (framedImageWidth / frameSize.width) / scale
        
    
        // Calculate the x, y coordinates for a centered square
        let xOffsetCentered = (imageWidth  - (framedImageWidth / scale)) / 2.0
        let yOffsetCentered = (imageHeight  - (framedImageHeight / scale)) / 2.0
        
        
        let cropRectOffsetX = xOffsetCentered - (xOffset * offsetScale)
        let cropRectOffsetY = yOffsetCentered - (yOffset * offsetScale)


        let cropRect = CGRect(x: xOffsetCentered - (xOffset * offsetScale )  , y: yOffsetCentered - (yOffset * offsetScale)  , width: framedImageWidth / scale  , height:  framedImageHeight / scale ).integral
   
        return (cropRect, cropRectOffsetX, cropRectOffsetY)
        
    }
    
    func cropImage(assetItem: AssetModel) -> UIImage?{
        print("crop image asset function called")
        guard let inputImage = assetItem.image else{ 
            print("inputImage does not have image [inside cropImage]")
            return nil}
      
        let (cropZone, _, _) = calculateCropRect(assetItem: assetItem)
        
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            print("fail to crop image. \(inputImage)")
            return nil
        }
    
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    func cropImage(assetItem: AssetModel, inputImage: UIImage) -> UIImage?{
       
        
        let (cropZone, _, _) = calculateCropRect(assetItem: assetItem)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            print("fail to crop image. \(inputImage)")
            return nil
        }
    
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    

    func cropVideoAsset(assetItem: AssetModel) async throws -> URL {
        print("crop video asset function called")
        guard assetItem.asset.mediaType == .video else {
            throw URLError(.badURL)
        }

        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = .original

        let playerItem = try await PHImageManager.default().requestPlayerItem(for: assetItem.asset, options: requestOptions)

        // Calculate the desired crop rectangle
        let (cropRect, cropRectOffsetX, cropRectOffsetY) =   calculateCropRect(assetItem: assetItem)

        // Define the output URL for the cropped video
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        // Call the cropAndExportVideoTrack1 function from the extension
        do {
            let url = try await playerItem.asset.cropAndExportVideoTrack1(
                at: 0,
                cropRect: cropRect,
                cropRectOffsetX: cropRectOffsetX,
                cropRectOffsetY: cropRectOffsetY,
                outputURL: tempURL
            )
            return url
        } catch {
            // Clean up the temporary file if an error occurs
            try? FileManager.default.removeItem(at: tempURL)
            throw error
        }
    }
    
    
    func saveImageToStorage(image: UIImage, uploadType: UploadType , compression: ImageCompressionOption = .jpg(compressionQuality: 1)) async throws -> String {
        guard let url = try? await FireBaseUploader.shared.uploadImage(uploadType: uploadType, image: image, compression: compression) else {
            throw URLError(.badServerResponse)
        }
        return url.absoluteString
    }

    
    func saveVideoToStorage(url: URL, uploadType: UploadType) async throws -> String{
        guard let url = try? await FireBaseUploader.shared.uploadVideoToStorage(uploadType: uploadType, url: url) else{
            throw URLError(.badServerResponse)
        }
        return url.absoluteString
    }
    
    func savePostToFirebase(user: DBUser) async throws{
        let postId = UUID().uuidString
        do{
            let uploadedUrls = try await uploadPost()
            let (urls, imageUrls, thumbnailUrls) = getUrls(urls: uploadedUrls)
            let post = Post(id: postId, ownerUid: user.id, caption: caption, urls: urls, imageUrls: imageUrls, thumbnailUrls: thumbnailUrls, aspectRaio: aspectRatioGeneral, ownerUsername: user.username ?? "unknown", ownerPhotoUrl: user.photoUrl ?? "empty")
            try await PostManager.shared.uploadPost(post: post)
            
        } catch{
            throw URLError(.badServerResponse)
        }
      
        updateProgress()
        self.postId = postId
        print("successfully saved to firestore [from image picker view model")
    }
    

    
    
    
    func uploadStory() async throws -> UploadedUrls{
        var  uploadedUrls = UploadedUrls(imageUrl: "", thumbnailUrl: "", videoUrl: "")
        
        do{
            let preparedAssets = try await preparAssets()
            let readyAssets = preparedAssets.0
            let readyThumbnails = preparedAssets.1
            for (index, item) in readyAssets.enumerated(){
                if let image = item as? UIImage{
                    print("cropped item is an image")
                    let imageUrl = try await saveImageToStorage(image: image, uploadType: .storyImage)
                    let thumbnailUrl = try await saveImageToStorage(image: image,  uploadType: .storyImage, compression: .jpg(compressionQuality: 0.1))

                    uploadedUrls.imageUrl = imageUrl
                    uploadedUrls.thumbnailUrl = thumbnailUrl
                    
                    updateProgress()
                } else if let url = item as? URL{
                    print("cropped item is a url to video")
                    let imageUrl = try await saveImageToStorage(image: readyThumbnails[index] , uploadType: .storyImage)
                    let thumbnailUrl = try await saveImageToStorage(image: readyThumbnails[index], uploadType: .storyImage, compression: .jpg(compressionQuality: 0.1))
                    let videoUrl = try await saveVideoToStorage(url: url , uploadType: .storyVideo)
                   
                    uploadedUrls.imageUrl = imageUrl
                    uploadedUrls.thumbnailUrl = thumbnailUrl
                    uploadedUrls.videoUrl = videoUrl
                    updateProgress()


                } else{
                    throw URLError(.badURL)
                }
            }
        } catch{
            throw URLError(.badURL)
        }
        print("uplaoding data into storage is done)")
        return uploadedUrls
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
    
    
    func uploadPost() async throws -> [UploadedUrls]{
        var  uploadedUrlsList: [UploadedUrls] = []
        
        do{
            let preparedAssets = try await preparAssets()
            let readyAssets = preparedAssets.0
            let readyThumbnails = preparedAssets.1
            for (index, item) in readyAssets.enumerated(){
                if let image = item as? UIImage{
                    print("cropped item is an image")
                    let imageUrl = try await saveImageToStorage(image: image, uploadType: .postImage)
                    let thumbnailUrl = try await saveImageToStorage(image: image,  uploadType: .postImage, compression: .jpg(compressionQuality: 0.1))

                    var uploadedUrls = UploadedUrls(imageUrl: "", thumbnailUrl: "")
                    uploadedUrls.imageUrl = imageUrl
                    uploadedUrls.thumbnailUrl = thumbnailUrl
                    uploadedUrlsList.append(uploadedUrls)
                    
                    updateProgress()
                } else if let url = item as? URL{
                    print("cropped item is a url to video")
                    let imageUrl = try await saveImageToStorage(image: readyThumbnails[index] , uploadType: .postImage)
                    let thumbnailUrl = try await saveImageToStorage(image: readyThumbnails[index], uploadType: .postImage, compression: .jpg(compressionQuality: 0.1))
                    let videoUrl = try await saveVideoToStorage(url: url , uploadType: .postVideo)
                   
                    var uploadedUrls = UploadedUrls(imageUrl: "", thumbnailUrl: "")
                    uploadedUrls.imageUrl = imageUrl
                    uploadedUrls.thumbnailUrl = thumbnailUrl
                    uploadedUrls.videoUrl = videoUrl
                    uploadedUrlsList.append(uploadedUrls)

                    updateProgress()
                    


                } else{
                    throw URLError(.badURL)
                }
            }
        } catch{
            throw URLError(.badURL)
        }
        print("uplaoding data into storage is done)")
        return uploadedUrlsList
    }
    
    
    
    func uploadListing() async throws -> [UploadedUrls]{
        var  uploadedUrlsList: [UploadedUrls] = []
        
        do{
            let preparedAssets = try await preparAssets()
            let readyAssets = preparedAssets.0
            let readyThumbnails = preparedAssets.1
            for (index, item) in readyAssets.enumerated(){
                if let image = item as? UIImage{
                    print("cropped item is an image")
                    let imageUrl = try await saveImageToStorage(image: image, uploadType: .listingImage)
                    let thumbnailUrl = try await saveImageToStorage(image: image,  uploadType: .listingImage, compression: .jpg(compressionQuality: 0.1))

                    var uploadedUrls = UploadedUrls(imageUrl: "", thumbnailUrl: "")
                    uploadedUrls.imageUrl = imageUrl
                    uploadedUrls.thumbnailUrl = thumbnailUrl
                    uploadedUrlsList.append(uploadedUrls)
                    
                    updateProgress()
                } else if let url = item as? URL{
                    print("cropped item is a url to video")
                    let imageUrl = try await saveImageToStorage(image: readyThumbnails[index] , uploadType: .listingImage)
                    let thumbnailUrl = try await saveImageToStorage(image: readyThumbnails[index], uploadType: .listingImage, compression: .jpg(compressionQuality: 0.1))
                    let videoUrl = try await saveVideoToStorage(url: url , uploadType: .listingVideo)
                   
                    var uploadedUrls = UploadedUrls(imageUrl: "", thumbnailUrl: "")
                    uploadedUrls.imageUrl = imageUrl
                    uploadedUrls.thumbnailUrl = thumbnailUrl
                    uploadedUrls.videoUrl = videoUrl
                    uploadedUrlsList.append(uploadedUrls)

                    updateProgress()
                    


                } else{
                    throw URLError(.badURL)
                }
            }
        } catch{
            throw URLError(.badURL)
        }
        print("uplaoding data into storage is done)")
        return uploadedUrlsList
    }
    
    func uploadMessage() async throws -> [UploadedUrls]{
        var  uploadedUrlsList: [UploadedUrls] = []
        
        do{
            let preparedAssets = try await preparAssets()
            let readyAssets = preparedAssets.0
            let readyThumbnails = preparedAssets.1
            for (index, item) in readyAssets.enumerated(){
                if let image = item as? UIImage{
                    print("cropped item is an image")
                    let imageUrl = try await saveImageToStorage(image: image, uploadType: .messageImage)
                    let thumbnailUrl = try await saveImageToStorage(image: image,  uploadType: .messageImage, compression: .jpg(compressionQuality: 0.1))

                    var uploadedUrls = UploadedUrls(imageUrl: "", thumbnailUrl: "")
                    uploadedUrls.imageUrl = imageUrl
                    uploadedUrls.thumbnailUrl = thumbnailUrl
                    uploadedUrlsList.append(uploadedUrls)
                    
                    updateProgress()
                } else if let url = item as? URL{
                    print("cropped item is a url to video")
                    let imageUrl = try await saveImageToStorage(image: readyThumbnails[index] , uploadType: .messageImage)
                    let thumbnailUrl = try await saveImageToStorage(image: readyThumbnails[index], uploadType: .messageImage, compression: .jpg(compressionQuality: 0.1))
                    let videoUrl = try await saveVideoToStorage(url: url , uploadType: .messageVideo)
                   
                    var uploadedUrls = UploadedUrls(imageUrl: "", thumbnailUrl: "")
                    uploadedUrls.imageUrl = imageUrl
                    uploadedUrls.thumbnailUrl = thumbnailUrl
                    uploadedUrls.videoUrl = videoUrl
                    uploadedUrlsList.append(uploadedUrls)

                    updateProgress()
                    


                } else{
                    print("failed to upload image/video to storage")
                    throw URLError(.badURL)
                }
            }
        } catch{
            throw URLError(.badURL)
        }
        print("uplaoding data into storage is done)")
        return uploadedUrlsList
    }
    
    
    func saveStoryToFirebase(uid: String) async throws{
        let storyId = UUID().uuidString
        do{
            let uploadedUrls = try await uploadStory()
            let story = Story(id: storyId, ownerUid: uid, imageUrl: uploadedUrls.imageUrl, thumbnailUrl: uploadedUrls.thumbnailUrl, videoUrl: uploadedUrls.videoUrl, aspectRaio: aspectRatioGeneral)
            try await PostManager.shared.uploadStory(story: story)
            
        } catch{
            throw URLError(.badServerResponse)
        }
        //completedUploadingSteps += 1
        updateProgress()
        self.postId = postId
        print("successfully saved to firestore [from image picker view model")
    }
    
    
    func cropImages() async throws {
        for assetItem in selectedAssets {
            guard let croppedItem = cropImage(assetItem: assetItem) else { throw URLError(.badURL)}
            self.croppedImages.append(croppedItem)
        }
    }
    
    func preparAssets() async throws -> ([Any], [UIImage]) {
        var croppedItems: [Any] = []
        var croppedThumbnails: [UIImage] = []
        
        for (index, assetItem) in selectedAssets.enumerated() {
            if assetItem.asset.mediaType == .image {
                // Crop image synchronously
                
                guard let croppedItem = cropImage(assetItem: assetItem) else { throw URLError(.badURL)}
                croppedItems.append(croppedItem)
                croppedThumbnails.append(croppedItem)
                updateProgress()
                
            } else {
                do {
                    // Crop video asynchronously
                    let croppedVideo = try await cropVideoAsset(assetItem: assetItem)
                    let thumbnail = try await loadThumbnail(assetItem: assetItem)
                    guard let croppedThumbnail = cropImage(assetItem: assetItem, inputImage: thumbnail) else {throw URLError(.badURL)}
                    croppedItems.append(croppedVideo)
                    croppedThumbnails.append(croppedThumbnail)

                    updateProgress()

                } catch {
                    print("error in cropping video")
                    throw URLError(.badURL)
                }
            }
            
           
        }
        print("crop job is done! >>>>>>>> number of items: \(croppedItems.count)")
        return (croppedItems, croppedThumbnails)
    }
    
    
    func updateProgress(){
        
        DispatchQueue.main.async {
            
                self.completedUploadingSteps += 1
               print("progress updated \(self.completedUploadingSteps)")

            
        }
    }
    
    

    
}



extension AVAsset {
    
    func cropAndExportVideoTrack1(at index: Int, cropRect: CGRect, cropRectOffsetX: CGFloat, cropRectOffsetY: CGFloat, outputURL: URL ) async throws -> URL {

        // Ensure the track index is valid
        guard let tracks = try? await loadTracks(withMediaType: .video), index < tracks.count else {
            throw URLError(.badURL)
        }

        // Fetch the video track to crop
        let videoTrack = tracks[index]
        // Use videoTrack as needed

         

        // Set up video composition properties
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = cropRect.size
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)

        let instruction = AVMutableVideoCompositionInstruction()
        //instruction.timeRange = CMTimeRange(start: .zero, duration: videoTrack.timeRange.duration)
        
        guard let timerange = try? await CMTimeRange(start: .zero, duration: videoTrack.load(.timeRange).duration)  else {
            throw URLError(.badURL)

        }
        
        instruction.timeRange = timerange

        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        
        enum Orientation {
            case up, down, right, left
        }

        func orientation(for track: AVAssetTrack) async throws -> Orientation? {
            guard let t = try? await track.load(.preferredTransform) else { return nil}

            if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {             // Portrait
                return .up
            } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {      // PortraitUpsideDown
                return .down
            } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {       // LandscapeRight
                return .right
            } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {     // LandscapeLeft
                return .left
            } else {
                return .up
            }
        }

        guard let trackOrientation = try? await orientation(for: videoTrack) else{
            throw URLError(.badURL)

        }
        
        guard let originalSize = try? await videoTrack.load(.naturalSize) else{
            throw URLError(.badURL)

        }

        var finalTransform: CGAffineTransform = CGAffineTransform.identity //
        
        print( "orientation: \(trackOrientation)")

        // Apply transformations to crop the video based on orientation
        if trackOrientation == .up {
            finalTransform = finalTransform
                .translatedBy(x: originalSize.height - cropRectOffsetX, y: -cropRectOffsetY)
                .rotated(by: CGFloat(90.0 * .pi / 180.0))
            transformer.setTransform(finalTransform, at: .zero)
        } else if trackOrientation == .down {
            finalTransform = finalTransform
                .translatedBy(x: originalSize.height - cropRectOffsetX, y: -cropRectOffsetY)
                .rotated(by: CGFloat(90.0 * .pi / 180.0))
            transformer.setTransform(finalTransform, at: .zero)
        } else if trackOrientation == .right {
            finalTransform = finalTransform.translatedBy(x: -cropRectOffsetX, y: -cropRectOffsetY)
            transformer.setTransform(finalTransform, at: .zero)
        } else if trackOrientation == .left {
            finalTransform = finalTransform.translatedBy(x: -cropRectOffsetX, y: -cropRectOffsetY)
            transformer.setTransform(finalTransform, at: .zero)
        }
        
        
        //print("finalTransform    >>>>>>>>>>>>>>>> \(finalTransform)")

        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        //print("instruction    >>>>>>>>>>>>>>>> \(instruction)")
        //print("videoComposition    >>>>>>>>>>>>>>>> \(videoComposition)")


        // Create an AVAssetExportSession for the cropped video segment
        guard let exporter = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetHighestQuality) else {
          
            throw URLError(.badURL)

            }
        
        
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputURL
        exporter.outputFileType = AVFileType.mov

        // Export the cropped video segment
        
        await exporter.export()
        
        return outputURL
        
       
    }
    
    
    
  
}


extension PHImageManager {
    func requestPlayerItem(for asset: PHAsset, options: PHVideoRequestOptions? = nil) async throws -> AVPlayerItem {
        return try await withCheckedThrowingContinuation { continuation in
            requestPlayerItem(forVideo: asset, options: options) { playerItem, info in
                if let playerItem = playerItem {
                    continuation.resume(returning: playerItem)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "com.yourapp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve AVPlayerItem"]))
                }
            }
        }
    }
}


