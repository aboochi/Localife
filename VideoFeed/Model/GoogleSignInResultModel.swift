//
//  GoogleSignInResultModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import SwiftUI

struct GoogleSignInResultModel{
    
    let idToken: String
    let accessToken: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let imageURL: URL?
}


