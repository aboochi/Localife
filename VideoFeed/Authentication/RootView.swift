//
//  RootView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import SwiftUI

struct RootView: View {
    
    @StateObject var session = AuthenticationViewModel()

    var body: some View{
        
        ZStack{
        
            switch  session.authState {
            case .authenticated:
                OnboardingView()
                    .environmentObject(session)
                   
            case .unauthenticated:
                AuthenticationView()
                    .environmentObject(session)
   
            case .none:
                SplashScreen()
                   
                    
            }
        }
    
 
    }
}

#Preview {
    RootView()
}
