//
//  FireBaseUploader.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/29/24.
//

import Foundation
import FirebaseStorage
import UIKit
import AVFoundation



enum UploadType {
    case profile
    case postImage
    case postVideo
    case storyImage
    case storyVideo
    case listingImage
    case listingVideo
    case messageImage
    case messageVideo
    
    
    
    var filePath: String {
        let filename = NSUUID().uuidString
        switch self {
        case .profile:
            return "/profileImages/\(filename)"
        case .postImage:
            return  "/postImages/\(filename)"
        case .postVideo:
            return  "/postVideos/\(filename)"
        case .storyImage:
            return  "/storyImage/\(filename)"
        case .storyVideo:
            return  "/storyVideo/\(filename)"
        case .listingImage:
            return  "/listingImage/\(filename)"
        case .listingVideo:
            return  "/listingVideo/\(filename)"
        case .messageImage:
            return  "/messageImage/\(filename)"
        case .messageVideo:
            return  "/messageVideo/\(filename)"
        }
    }
}


final class FireBaseUploader{
    
    static let shared = FireBaseUploader()
    private init() {}
    
    
    func uploadImage(uploadType: UploadType, image: UIImage, compression: ImageCompressionOption) async throws -> URL {
        guard let data = compression.compress(image: image) else {
            throw FirebaseStorageError.unableToConvertToData
        }
        
        let ref = referenceForPath(uploadType: uploadType, ext: compression.ext)
        return try await save(data: data, reference: ref, meta: compression.meta)
    }
    

    // MARK: PRIVATE
    
    private func referenceForPath(uploadType: UploadType, ext: String) -> StorageReference {
        
        let path = "\(uploadType.filePath).\(ext)"
        return Storage.storage().reference(withPath: path)
    }
    
    private func save(data: Data, reference: StorageReference, meta: StorageMetadata) async throws -> URL {
        let _ = try await reference.putDataAsync(data, metadata: meta)
        return try await reference.downloadURL()
    }

    
    
    
    func uploadVideoToStorage(uploadType: UploadType, url: URL, ext: String = ".mp4") async throws -> URL{
       
       do{
           let mediaData = try Data(contentsOf: url)
           
           let path = "\(uploadType.filePath).\(ext)"
           
           print("Uploading video from URL: \(url.path)")
           print("Uploading path : \(path)")

           let storageRef = Storage.storage().reference(withPath: path)
           
           // Determine the MIME type
           let mimeType = mimeTypeForVideo(at: url) ?? "video/mp4"
           let metaData = StorageMetadata()
           metaData.contentType = mimeType
           print("metadata: \(metaData)")
          
           
           let _ = try await storageRef.putDataAsync(mediaData, metadata: metaData)
           let uploadedURL = try await storageRef.downloadURL()
           return uploadedURL
           
           
       }catch{
           print(" Error uploading video into Storage: \(error)")
           throw FirebaseStorageError.unableToConvertToData
       }
    
   }

       enum FirebaseStorageError: Error {
           case unableToFindUrl, unableToConvertToData
       }
    
    
    
    func mimeTypeForVideo(at url: URL) -> String? {
        let asset = AVAsset(url: url)
        guard let formatDescriptions = asset.tracks(withMediaType: .video).first?.formatDescriptions as? [CMFormatDescription] else {
            return nil
        }
        let formatDescription = formatDescriptions.first!
        let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
        
        switch codecType {
        case kCMVideoCodecType_H264:
            return "video/mp4"
        case kCMVideoCodecType_HEVC:
            return "video/hevc"
        case kCMVideoCodecType_JPEG:
            return "video/mjpeg"
        case kCMVideoCodecType_AppleProRes422:
            return "video/x-prores"
        default:
            return "video/mp4"
        }
    }
    
}
