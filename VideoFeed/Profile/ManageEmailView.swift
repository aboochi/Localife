//
//  ManageEmailView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/6/24.
//

import SwiftUI

struct ManageEmailView: View {
    @Environment(\.dismiss) var dismiss
    @State var reAuthenticationConfirmed: Bool = false
    @State var reLoginAfterEmailChange: Bool = false
    @State var isVerified: Bool = false
    var body: some View {
        
        if reAuthenticationConfirmed && !isVerified{
            
            ChangeEmailView(isVerified: $isVerified)
            
        }else if !reAuthenticationConfirmed || !reLoginAfterEmailChange{
            
            ReAuthenticationView(reAuthenticationConfirmed: $reAuthenticationConfirmed, isVerified: $isVerified, reLoginAfterEmailChange: $reLoginAfterEmailChange)
        } else{
            
            Color.clear
           
                .onAppear{
                    dismiss()
                }
        }
    }
}

