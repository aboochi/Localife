//
//  AddAuthMethodView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/7/24.
//

import SwiftUI
import FirebaseAuth

struct AddAuthMethodView: View {
    
    @EnvironmentObject var session : AuthenticationViewModel
    @EnvironmentObject var viewModel: ProfileViewModel
    @Environment(\.dismiss)  var dismiss
    @State var email: String = ""
    @State var errorMessage: String = ""
    
    var body: some View {
        
        ScrollView(showsIndicators: false){
            VStack(spacing: 10){
                
               
                
                Group {
                    
                    if session.providerEmails.count > 0{
                        
                        
                        
                        Text("You can link your existing ")
                        + Text("Localife").fontWeight(.bold)
                        + Text(" account to additional authentication providers to have multiple login options in the future.")
                    }else{
                        Text("You joined as a guest. We strongly recommend that you choose one of the following options to authenticate your existing account.")
                    }
                }
                .font(.system(size: 13, weight: .light))
                .foregroundColor(.gray)
                
                linkToGoogle
                linkToApple
                addEmailPassword
                Text(errorMessage)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.red)
      

            }
            .padding()
        }
    }
    
    
    @ViewBuilder
    var linkToGoogle: some View{
        
        if let provider = session.dbUser.authProviders, !provider.contains(AuthProviderOption.google.rawValue){
            
            Button {
                
                Task{
                    do{
                        try await session.linkGoogle()
                         try await session.getProviderEmails()
                        if session.providerEmails.count > 1{
                            dismiss()
                        }
                        
                        print(" google linked")
                    } catch{
                        print(error)
                        errorMessage = error.localizedDescription
                    }
                }
                
                
                
            } label: {
                
                HStack{
                    
                    Image("google-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text("Link Google Account")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                
            }
        }
    }
  
    @ViewBuilder
    var linkToApple: some View{
        
        if let provider = session.dbUser.authProviders, !provider.contains(AuthProviderOption.apple.rawValue){
            
            Button {
                
                
                Task{
                    do{
                        try await session.linkApple()
                        try await session.getProviderEmails()
                        if session.providerEmails.count > 1{
                            dismiss()
                        }
                        print("apple linked")
                    } catch{
                        print(error)
                        errorMessage = error.localizedDescription

                    }
                }
                
                
                
            } label: {
                
                HStack{
                    
                    Image(systemName: "apple.logo")
                        .imageScale(.large)
                    
                    Text("Link Apple account")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.black)
                .cornerRadius(10)
                
            }
        }

    }
    
    
    @ViewBuilder
    var addEmailPassword: some View{
        
        if let provider = session.dbUser.authProviders, !provider.contains(AuthProviderOption.email.rawValue){
            
            
            
            NavigationLink {
                
                SignUpEmailView(email: $email, signUpType: .link )
                
                
            } label: {
                
                HStack{
                    
                    Image(systemName: "envelope")
                        .imageScale(.large)
                        
                    
                    Text("Link to Email")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                
            }
        
        }
    }
    
    
}


