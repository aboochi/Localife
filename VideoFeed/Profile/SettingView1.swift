//
//  SettingView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/6/24.
//

import SwiftUI

struct SettingView1: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ProfileViewModel

    let cellHeight = 37.0
    var body: some View {
        List(){
            
           
                NavigationLink {
                    
                    CredentialsView()
                        .environmentObject(session)
                        .environmentObject(viewModel)
                    
                } label: {
                    Label("Credentials", systemImage: "key")
                        .frame(height: cellHeight)
                }
                
                NavigationLink {
                    
                    PrivacySettingsView()
                        .environmentObject(session)
                        .environmentObject(viewModel)

                    
                } label: {
                    Label("Account Privacy", systemImage: "lock")
                        .frame(height: cellHeight)
                }
                
                NavigationLink {
                    NotificationSetting()
                        .environmentObject(session)
                        .environmentObject(viewModel)
                } label: {
                    Label("Notifications", systemImage: "bell")
                        .frame(height: cellHeight)

                }
            
            
            NavigationLink {
                LocationEditOptionView()
                    .environmentObject(session)
                    .environmentObject(viewModel)
                
                    .environmentObject(LocationSetupViewModel(user: session.dbUser))
            } label: {
                Label("Location", systemImage: "location")
                    .frame(height: cellHeight)

            }
                
                NavigationLink {
                    
                    BlockedUsersView()
                        .environmentObject(session)
                        .environmentObject(viewModel)
                    
                    
                } label: {
                    Label("Blocked users", systemImage: "wrongwaysign")
                        .frame(height: cellHeight)

                }
                
                NavigationLink {
                    
                    SavedContentView()
                        .environmentObject(session)
                        .environmentObject(viewModel)
                    
                } label: {
                    Label("Saved", systemImage: "bookmark")
                        .frame(height: cellHeight)

                }
                
                NavigationLink {
                    
                    HelpView()
                    
                } label: {
                    Label("Help", systemImage: "questionmark.circle")
                        .frame(height: cellHeight)

                }
                
//                NavigationLink {
//                    
//                } label: {
//                    Label("About", systemImage: "info.square")
//                        .frame(height: cellHeight)
//
//                }
                
                
               
                Button {
                    
                    Task{
                        do{
                            try session.signOut()
                        } catch{
                            print(error)
                        }
                    }
                    
                } label: {
                    Text("Log out")
                        .foregroundColor(.red)
                        .frame(height: cellHeight)
                        .padding(.horizontal, 5)
                    
                }
                
            
        
            
        }
        .foregroundColor(.black)
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingView()
}
