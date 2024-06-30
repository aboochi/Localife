//
//  FileManagerHelper.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/2/24.
//

import Foundation

final class FileManagerHelper{
    
    static let shared = FileManagerHelper()
    
    private init(){}
    
    
    
    func downloadAndSaveMedia(from url: URL, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Check for any errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Data is nil", code: 0, userInfo: nil)))
                return
            }
            
            // Create a unique URL for saving the video
            let documentsDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let videoURL = documentsDirectoryURL.appendingPathComponent(path + ".mp4")
            
            // Save the video data to the local file system
            do {
                try data.write(to: videoURL)
                completion(.success(videoURL))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func downloadAndSaveMedia(from url: URL, path: String) async throws -> URL {
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            // Create a unique URL for saving the video
            let documentsDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let videoURL = documentsDirectoryURL.appendingPathComponent(path + ".mp4")
            
            // Save the video data to the local file system
            try  data.write(to: videoURL)
            print("file successfully cached")
            return videoURL
        }catch{
            print("file failed to cached")

            throw error
        }
    }

    
    
    
    func deleteFile(path: String) {
        let docsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent(path + ".mp4")
        if let destinationUrl = destinationUrl {
            guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
                print("File deleted successfully")
            } catch let error {
                print("Error while deleting video file: ", error)
            }
        }
    }

    func checkFileExists(path: String) -> URL? {
        let docsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let destinationUrl = docsUrl?.appendingPathComponent(path + ".mp4")
        
        if let destinationUrl = destinationUrl,
           FileManager().fileExists(atPath: destinationUrl.path) {
            
            print("file exists")
            // File exists, return the URL
            return destinationUrl
        } else {
            // File doesn't exist, return nil
            return nil
        }
    }

    
}
