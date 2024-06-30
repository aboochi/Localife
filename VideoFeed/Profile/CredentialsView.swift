//
//  CredentialsView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/6/24.
//

import SwiftUI

struct CredentialsView: View {
    
    
    @EnvironmentObject var session : AuthenticationViewModel
    @EnvironmentObject var viewModel: ProfileViewModel
    @State private var showAlert = false
    @State var showReauthentication: Bool = false
    @State var deleteFailed: Bool = false
    @State var reAuthenticationConfirmed: Bool = false
    
    
    var body: some View {
        
        Group{
            if  session.providerEmails.count > 0{
                
                Form{
                    
                    Section("Your Authenticaion Methods"){
                        
                        
                        ForEach(Array(session.providerEmails), id: \.key) { method, email in
                            
                            
                            if method == AuthProviderOption.apple.rawValue{
                                Label(email, systemImage: "apple.logo")
                                    .foregroundColor(.black)
                                
                            }else if method == AuthProviderOption.google.rawValue{
                                
                                
                                Label {
                                    Text(email)
                                } icon: {
                                    Image("google-logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                }
                                
                            }else if method == AuthProviderOption.email.rawValue{
                                Label(email, systemImage: "envelope")
                                    .foregroundColor(.black)
                                
                            }
                        }
                    }
                    
                    
                    if let providerId = session.providerEmails[AuthProviderOption.email.rawValue]{
                        
                        Section{
                            
                            NavigationLink {
                                
                                ManageEmailView()
                                    .environmentObject(session)
                                
                            } label: {
                                
                                Text("Change Email")
                                
                            }
                            
                            
                            NavigationLink {
                                
                                ManagePasswordView()
                                    .environmentObject(session)
                                
                            } label: {
                                
                                Text("Change Password")
                                
                            }
                        }
                    }
                    
                    if session.providerEmails.count < 3{
                        
                        Section{
                            
                            NavigationLink {
                                
                                AddAuthMethodView()
                                    .environmentObject(session)
                                
                            } label: {
                                Text("Add more authentication methods")
                            }
                            
                        }
                    }
                    
                    deleteAccountButton
                    
                }
                
            }else{
               
                VStack(alignment: .leading){
                    AddAuthMethodView()
                        .environmentObject(session)
                    
                    
                    deleteAccountButton
                        .padding()
                    
                    Spacer()
                }

            }
            
       
        }
        .onAppear{
            Task{
                try await session.getProviderEmails()
            }
        }
    }
    
    
    var deleteAccountButton: some View{
        
        Button(action: {
                        showAlert = true
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.red)
                         
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                Task {
                                    do{
                                        try await session.deleteAccount()
                                        session.authState = .unauthenticated
                                    }catch{
                                        deleteFailed = true
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
        
                    .onChange(of: deleteFailed) { oldValue, newValue in
                        if newValue{
                            showReauthentication = true
                            deleteFailed = false

                        }
                        
                    }
                    .onChange(of: reAuthenticationConfirmed, { oldValue, newValue in
                        if newValue{
                            showReauthentication = false
                            Task{
                                do{
                                    try await session.deleteAccount()
                                    session.authState = .unauthenticated
                                }catch{
                                    deleteFailed = true
                                }
                            }
                        }
                    })
                    .sheet(isPresented: $showReauthentication, content: {
                        ReAuthenticationView(reAuthenticationConfirmed: $reAuthenticationConfirmed, isVerified: .constant(false), reLoginAfterEmailChange: .constant(false))
                    })
    }
    
}

#Preview {
    CredentialsView()
}
