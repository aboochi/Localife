//
//  AuthDataUserModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import SwiftUI
import FirebaseAuth

struct AuthDataUserModel {
    
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    let user: User
    let providers: [String]?
    
    init(user: User){
        
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
        self.user = user
        self.providers = []
    }
    

    
}


