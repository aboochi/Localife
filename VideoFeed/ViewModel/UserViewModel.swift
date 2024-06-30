//
//  ProfileViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/29/24.
//

import SwiftUI

class UserViewModel: ObservableObject {
    
    @Published var dbUser: DBUser?
    var  authUser: AuthDataUserModel?
    
    init()  {
        Task{
            dbUser = try? await getDBUser()
        }
    }
    
    func getDBUser() async throws -> DBUser?{
        do{
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            self.authUser = authUser
            let dbUser = try await UserManager.shared.getUser(userId: authUser.uid)
            return dbUser
        } catch {
            return nil
        }
    }
    
    
    func saveImageToStorage( image: UIImage, compression: ImageCompressionOption = .jpg(compressionQuality: 1)) async throws -> URL {
        try await FireBaseUploader.shared.uploadImage(uploadType: .profile, image: image, compression: compression)
        }
    
    func storePhtoUrltoFirestore(url: String) async throws{
        guard let uid = dbUser?.id else { return }
        
        print("uid:    \(uid)")

        try await UserManager.shared.updateUserPhotoURL(userId: uid, url: url)
        
        try await dbUser = UserManager.shared.getUser(userId: uid)
   
    }
    
    func saveProfileImage(image: UIImage) async throws {
        
        let url = try await saveImageToStorage(image: image)
        if var user = dbUser{
            user.photoUrl = url.absoluteString
        }
        try await storePhtoUrltoFirestore(url: url.absoluteString)
        
    }
    
    

}

