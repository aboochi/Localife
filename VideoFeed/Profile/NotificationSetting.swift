//
//  NotificationSetting.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/6/24.
//

import SwiftUI

struct NotificationSetting: View {
    
    @EnvironmentObject var session : AuthenticationViewModel
    @EnvironmentObject var viewModel: ProfileViewModel

    var body: some View {
        Form {
            
            
            Toggle("Enable Notifications", isOn: $session.dbUser.allowNotification)
                            .padding()
                            .onChange(of: session.dbUser.allowNotification) { _, newValue in
                                // Perform action when the toggle is toggled
                                if newValue {
                                 
                                    session.userViewModel.dbUser?.allowNotification = true
                                    Task{
                                        try await viewModel.updateNotificationSetting(enable: true)
                                    }
                                } else {
                                  
                                    session.userViewModel.dbUser?.allowNotification = false
                                    Task{
                                        try await viewModel.updateNotificationSetting(enable: false)
                                    }


                                }
                            }
            
            
        }
        .navigationTitle("Notifications")
    }
}


