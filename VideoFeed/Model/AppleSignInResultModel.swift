//
//  SignInWithAppleResultModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import SwiftUI
import AuthenticationServices

struct AppleSignInResultModel {
    
    let appleIDCredential: ASAuthorizationAppleIDCredential
    let idTokenString: String
    let nonce: String
    var firstName: String? {return appleIDCredential.fullName?.givenName}
    var lastName: String? {return appleIDCredential.fullName?.givenName}
    var email: String? {return appleIDCredential.email}
  
}


