//
//  AuthenticationViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/16/24.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth


enum AuthenticationState: Int {
    case unauthenticated = 0
    case authenticated = 1
}

enum OnboaringStage: Int {
    case usernameSetup = 0
    case avatarSetup = 1
    case locationPermision = 2
    case done = 3
}



@MainActor
final class AuthenticationViewModel: ObservableObject{
    @Published var authState: AuthenticationState?
    @Published var authUser: AuthDataUserModel?
    @Published var authProviders: [AuthProviderOption] = []
    @AppStorage("onBoardingStage") var onBoardingStage: OnboaringStage = .done
    @Published var dbUser: DBUser = DBUser(uid: "Dummy")
    @Published var providerEmails: [String: String] = [:]
    @Published var savedPostIds: [String] = []
    @Published var savedListingIds: [String] = []
    @Published var followerIds: [String] = []
    @Published var followingIds: [String] = []
    @Published var requestIds: [String] = []
    @Published var postSeenIds: [String] = []



  
    
    let userViewModel: UserViewModel
    private var cancellables = Set<AnyCancellable>()

    
    init(){
        
        userViewModel = UserViewModel()
 
        Task{
            
            do{
                self.authUser = try AuthenticationManager.shared.getAuthenticatedUser()
                try await getDbUser()
                if try await checkEmailVerification(){
                    self.authState = .authenticated
                }else{
                    try signOut()
                }
            } catch{
                try signOut()
                self.authState = .unauthenticated
            }
        }
        
        
        userViewModel.$dbUser
            .sink { [weak self] dbUser in
                
                DispatchQueue.main.async {
                    if let dbUser = dbUser {
                        self?.dbUser = dbUser
                    }
                }
                
            }
            .store(in: &cancellables)
    }
    
    func getDbUser() async throws{
        
        guard let authUser = Auth.auth().currentUser else{ return}
        let userDoc =  try await UserManager.shared.userDocument(userId: authUser.uid).getDocument()
        if userDoc.exists {
            self.dbUser = try userDoc.data(as: DBUser.self)
       
        }
    }
    
    
    
    func signUpEmail(email: String, password: String) async throws{
        guard !email.isEmpty, !password.isEmpty else{
            return
        }
        
        let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
        try await updateAuthentication(authProviderOption: .email, updateAll: false)
        
    }
    
    
    func signInEmail(email: String, password: String) async throws{
        guard !email.isEmpty, !password.isEmpty else{return}
        
        let returnedUserData = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        try await updateAuthentication(authProviderOption: .email, updateAll: false)
        
    }
    
    
    func signInGoogle()async throws{
        
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        do{
            try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
            try await updateAuthentication(firstName: tokens.firstName, lastName: tokens.lastName , authProviderOption: .google)
        } catch {
            
        }
    }
    
    
    func signInApple() async throws{
        
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        do{
            try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
            try await updateAuthentication(firstName: tokens.firstName, lastName: tokens.lastName, authProviderOption: .apple)
        }catch{
            
        }
        
        
    }
    
    func signInAnonymously() async throws{
        do{
            try await AuthenticationManager.shared.signInAnonymously()
            try await updateAuthentication(authProviderOption: .anonymous)
        }catch{
            
        }
        
    }
    
    
    func updateAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProvider(){
            authProviders = providers
            authState = .authenticated
        }
    }
    
    
    func signOut() throws{
        do{
            try AuthenticationManager.shared.singOut()
            self.authState = .unauthenticated
        }
    }
    
    func resetPassword(inputEmail: String? = nil) async throws{
        
        if let email = inputEmail{
            print("this part is executed")
            try await AuthenticationManager.shared.resetPassword(email: email)
        }else{
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            guard let email = authUser.email else {
                throw URLError(.fileDoesNotExist)
            }
            try await AuthenticationManager.shared.resetPassword(email: email)
        }
    }
    
    func updateEmail(email: String) async throws{
       print("new email: >>>>>>>>>>>.. \(email)")
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func verifyBeforeUpdateEmail(email: String) async throws{
       print("new email: >>>>>>>>>>>.. \(email)")
        try await AuthenticationManager.shared.verifyBeforeUpdateEmail(email: email)
    }
    
    func sendVerificationEmail() async throws{
        
        try await AuthenticationManager.shared.sendVerificationEmail()
    }
    
    
    func reAuthenticate(email: String, password: String) async throws{
        let credential = FirebaseAuth.EmailAuthProvider.credential(withEmail: email, password: password)
        try await AuthenticationManager.shared.reAuthenticate(auth: credential)
        
    }
    
    func updatePassword(password: String) async throws{
       
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogle() async throws{
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        //self.authUser = authDataResult
      
    }
    
    func linkApple() async throws{
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResult = try await AuthenticationManager.shared.linkApple(tokens: tokens)
        //self.authUser = authDataResult
   
    }
    
    func linkEmail(email: String, password: String) async throws{
        let authDataResult = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
        //self.authUser = authDataResult
   
    }
    

    func updateAuthentication(firstName: String? = "", lastName: String? = "", authProviderOption: AuthProviderOption, updateAll: Bool = true) async throws {
        guard let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() else {return}
        self.authUser = authUser
        self.userViewModel.authUser = authUser
        print("authUser updated: \(authUser.uid)")
        let userDoc =  try await UserManager.shared.userDocument(userId: authUser.uid).getDocument()
        if userDoc.exists {
            let fetchDbUser = try userDoc.data(as: DBUser.self)
            self.dbUser = fetchDbUser
            self.userViewModel.dbUser = fetchDbUser
            self.onBoardingStage = OnboaringStage(rawValue: dbUser.onBoaringState ?? 0 ) ?? .usernameSetup
            if updateAll{
                self.authState = .authenticated
            }
            return
        }
        self.authProviders = try AuthenticationManager.shared.getProvider()
        let databaseUser = DBUser(auth: authUser, provider: authProviders.map({ $0.rawValue }), firstName: firstName, lastName: lastName, authProviderOption: authProviderOption)
        self.dbUser = databaseUser
        self.userViewModel.dbUser = databaseUser
        self.onBoardingStage = OnboaringStage(rawValue: authUser.isAnonymous ? 3 : 0) ?? .done
        if updateAll{
            self.authState = .authenticated
        }
        try await UserManager.shared.createNewUser(user: databaseUser)
       
  
    }
    
    func updateUserOnboardingState(onBoardingState: Int) async throws{
        guard let uid = authUser?.uid else {return}
        
        try await UserManager.shared.updateUserOnboardingState(userId: uid, onBoardingState: onBoardingState)
    }
    
    func getProviderEmails() async throws {
        
        providerEmails =  try await AuthenticationManager.shared.getProviderEmails()
    }
    
    func checkEmailVerification() async throws -> Bool{
        print("checkEmailVerification called")
       // return try await AuthenticationManager.shared.checkEmailVerification()
        
        return true //this is for test purpose to skip email veirification
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
    
}

