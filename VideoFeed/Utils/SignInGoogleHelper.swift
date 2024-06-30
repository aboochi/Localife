//
//  SignInGoogleHelper.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift


final class SignInGoogleHelper{
    
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel{
        
        guard let topVC =  Utilities.shared.topViewController() else{
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else{
            throw URLError(.badServerResponse)
        }
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        let name: String? = gidSignInResult.user.profile?.name
        let email: String? = gidSignInResult.user.profile?.email
        let familyName: String? = gidSignInResult.user.profile?.familyName
        let GivenName: String? = gidSignInResult.user.profile?.givenName
        let imageURL: URL? = gidSignInResult.user.profile?.imageURL(withDimension: .max)

   





        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, firstName: GivenName, lastName: familyName, email: email, imageURL: imageURL )
        return tokens
        
    }
}
