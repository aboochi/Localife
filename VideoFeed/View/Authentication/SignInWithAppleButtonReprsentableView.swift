//
//  SignInWithAppleButtonReprsentableView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleButtonViewReprsentable: UIViewRepresentable {
    
    let type : ASAuthorizationAppleIDButton.ButtonType
    let style : ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) ->  ASAuthorizationAppleIDButton {
         ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
    
    
}


