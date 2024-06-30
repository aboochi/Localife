//
//  AuthenticationManager.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit


enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
    case anonymous = "anonymous"
}

final class AuthenticationManager{
    
    static let shared = AuthenticationManager()
    
    private init(){}
    
    func getAuthenticatedUser() throws -> AuthDataUserModel{
        guard let user = Auth.auth().currentUser else{
            print("failed to authenticate")
            throw URLError(.badServerResponse)
        }
        print("user >>>>> \(user.uid)")
        return AuthDataUserModel(user: user)
    }
    
    func singOut() throws{

        try Auth.auth().signOut()
    }
    
    func getProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else{
            throw URLError(.badServerResponse)
        }
        
        var providers : [AuthProviderOption] = []
        for provider in providerData{
            if let option = AuthProviderOption(rawValue: provider.providerID){
                
                providers.append(option)
                
            } else{
                assertionFailure("Provider Option Not Found! \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    
}





// MARK: Sign in Email
extension AuthenticationManager {
    
    func createUser(email: String, password: String) async throws -> AuthDataUserModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataUserModel(user: authDataResult.user)
    }
    
    func signInUser(email: String, password: String) async throws -> AuthDataUserModel{
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataUserModel(user: authDataResult.user)
    }
    
    
    
    func resetPassword(email: String) async throws{
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
    
    func reAuthenticate(auth: AuthCredential) async throws{
        
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        
        try await user.reauthenticate(with: auth)
    }
    
    func verifyBeforeUpdateEmail(email: String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
       
    }
    
    func sendVerificationEmail() async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        
       // try await user.sendEmailVerification(beforeUpdatingEmail: email)
       try await user.sendEmailVerification()
    }
    
    
    func getProviderEmails() async throws -> [String: String]{
        
        
        var result : [String: String] = [:]
        guard let providers = Auth.auth().currentUser?.providerData else{ return result }
        
        for provider in providers {
            if let email = provider.email{
                result[provider.providerID] = email
            }
        }
        
        return result
           
    }
    
    func checkEmailVerification() async throws  -> Bool {
        guard let result = Auth.auth().currentUser?.isEmailVerified else { return false}
        let providers = try await getProviderEmails()
        print("providers: \(providers.keys)")
        
         if providers.count == 1 && providers.keys.contains(AuthProviderOption.email.rawValue){
             print("is email authenticated: >>>>>> \(result)")
           return result
         }else{
             return true
         }
        
    }
    
    func deleteUser() async throws{
       
        guard let user = Auth.auth().currentUser else{ return }
        try await user.delete()
        
    }
    
}


// MARK: Sign in SSO

extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataUserModel{
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    
    
    @discardableResult
    func signInWithApple(tokens: AppleSignInResultModel) async throws -> AuthDataUserModel{
        let credential = OAuthProvider.appleCredential(withIDToken: tokens.idTokenString, rawNonce: tokens.nonce, fullName: tokens.appleIDCredential.fullName)
        
        return try await signIn(credential: credential)
    }
    
    
    func signIn(credential: AuthCredential) async throws -> AuthDataUserModel {
        
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataUserModel(user: authDataResult.user)
    }
    
    
    
}

// MARK: SIGN IN ANONYMOUSLY

extension AuthenticationManager{
    
    func signInAnonymously() async throws -> AuthDataUserModel {
        
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataUserModel(user: authDataResult.user)
    }
    
    
    func linkEmail(email: String, password: String) async throws -> AuthDataUserModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await linkCredential(credential: credential)
  
    }
    
    func linkApple(tokens: AppleSignInResultModel) async throws -> AuthDataUserModel {
        let credential = OAuthProvider.appleCredential(withIDToken: tokens.idTokenString, rawNonce: tokens.nonce, fullName: tokens.appleIDCredential.fullName)
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataUserModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredential(credential: credential)
    }
    
    func linkCredential(credential: AuthCredential) async throws -> AuthDataUserModel{
        
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataUserModel(user: authDataResult.user)
        
    }
}
