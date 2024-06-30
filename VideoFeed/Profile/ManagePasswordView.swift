//
//  ManagePasswordView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/6/24.
//

import SwiftUI

struct ManagePasswordView: View {
    @State var reAuthenticationConfirmed: Bool = false
    @State var passwordChanged: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        
        if reAuthenticationConfirmed && !passwordChanged{
            
            ChangePasswordView(passwordChanged: $passwordChanged)
            
        }else if !passwordChanged{
            
            ReAuthenticationView(reAuthenticationConfirmed: $reAuthenticationConfirmed , isVerified: .constant(false), reLoginAfterEmailChange: .constant(false))
        }else{
            
            Color.clear
           
                .onAppear{
                    dismiss()
                }
        }
    }
}
