//
//  AuthenticationView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignInSwift
import AuthenticationServices




struct AuthenticationView: View {
    
    @EnvironmentObject var session : AuthenticationViewModel
    @State var showEmailSignInView: Bool = false
    var body: some View {
        VStack{
            
         
            VStack{
                
              
                    LogoSplash(spacing: 15.0, color1: Color(hex: "#4169e1"), color2: .white)
                        .scaleEffect(0.4)
                        .foregroundColor(Color(hex: "#4169e1"))
                        .frame(width: 100, height: 100)
                    
                    Text("Live Your Localife")
                        .foregroundColor(.black)
                        .font(.system(size: 30, weight: .bold))
                    
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
      
            
            
            apple
            google
            emailPassword
            
            Spacer()
            anonymous
            termOfUse
            
            
            
           
     
        }
        .padding()
        .navigationTitle("Sing In")
    }
    
    
    
    @ViewBuilder
    var anonymous: some View{
        
        Button(action: {
            Task{
                do{
                    try await session.signInAnonymously()
                } catch{
                    print(error)
                }
            }
            
        }, label: {
            
            
            Text("Continue as Guest")
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: 45)
                .overlay(
                    Capsule()
                        .stroke(.black, lineWidth: 1)
                )
            
            
    
        })
    }
    
    @ViewBuilder
    var emailPassword: some View{
        
        Button(action: {
            showEmailSignInView = true

            
        }, label: {
            
            
            Label("Continue with Email", systemImage: "envelope")
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: 45)
                .overlay(
                    Capsule()
                        .stroke(.black, lineWidth: 1)
                )
            
      
               
        })
        .frame(height: 45)
        .fullScreenCover(isPresented: $showEmailSignInView, content: {
            EmailAuthTabView()
        })
    }
    
    
    
    
    @ViewBuilder
    var apple: some View{
        
        Button {
            
            Task{
                do{
                    try await session.signInApple()
                } catch{
                    
                    print("error sign in with Apple: \(error)")
                }
            }
            
            
            
            
        } label: {
            
            Label("Continue with Apple", systemImage: "apple.logo")
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: 45)
                .overlay(
                    Capsule()
                        .stroke(.black, lineWidth: 1)
                )
            
            
            
        }
        
    }
    
    
    
@ViewBuilder
    var google: some View{
        
        
        Button {
            
            Task{
                do{
                    try await session.signInGoogle()
                } catch{
                    print(error)
                }
            }
            
            
            
            
        } label: {
            
            VStack{
                Label {
                    Text("Continue with Google")
                        .font(.headline)
                        .foregroundColor(.black)
                } icon: {
                    Image("google-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 45)
            .overlay(
                Capsule()
                    .stroke(.black, lineWidth: 1)
            )

           
        }
    }
    
    @ViewBuilder
    var termOfUse: some View{
        
        Group{
            Text("By continuing, you agree to our ")
            
            +
            
            Text("Terms of Service ")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black.opacity(0.9))

            +
            
            Text("and acknowledge that you have read our ")
            
            +
            
            Text("Privacy Policy ")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black.opacity(0.9))
            
            +
            
            Text("to learn how we collect, use, and share your data.")
        }
        .font(.system(size: 12, weight: .light))
        .foregroundColor(.black.opacity(0.8))
        .multilineTextAlignment(.center)
        .padding(.top, 10)
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
    
    
}






