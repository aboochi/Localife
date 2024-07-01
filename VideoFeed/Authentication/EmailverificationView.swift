//
//  EmailverificationView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/7/24.
//

enum Emailverificationtype{
    case signUp
    case changeEmail
}

import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    @EnvironmentObject var session : AuthenticationViewModel
    @State private var progress: Double = 60
    @Binding  var isVerified: Bool
    @State private var timer: Timer?
    @State private var timeOver: Bool = true
    @State private var newLink: Bool = false
    let emailverificationType: Emailverificationtype
    let email: String
    @Binding var errorMessage: String
    
    
    var body: some View {
        VStack {
            
            if !isVerified && !timeOver{
                Text("We sent you a verification link to your email. please click on the link to continue")
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding()
                
                Text("waiting for email verification...")
                
            }else if isVerified {
            
                Text("Email verified!")
                
            }
            
            if !isVerified{
                Button {
                    progress = 60
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3){
                        startEmailVerificationCheck()
                    }
                    
                } label: {
                    if newLink{
                        Text("Send me another link")
                            .padding()
                    }else{
                        Text("Email me a verification link")
                    }
                }
            }
   
               
            
        }
        .onAppear {
            startEmailVerificationCheck()
        }
        .onDisappear {
            stopTimer()
            
            
        }
    }
    
    private func startEmailVerificationCheck() {
        Task{
            do{
                try await sendVerificationLink()
               
                timeOver = false
                progress = 0
                newLink = true
            }catch{
                errorMessage = error.localizedDescription
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if progress < 60 {
                progress += 1
                checkEmailVerification()
            } else {
                timer.invalidate()
                handleEmailNotVerified()
            }
        }
    }
    
    private func checkEmailVerification() {
        Auth.auth().currentUser?.reload { error in
            if let error = error {
                print("Error reloading user: \(error)")
                if error.localizedDescription == "The user's credential is no longer valid. The user must sign in again."{
                    timer?.invalidate()
                    isVerified = true
                }
                return
            }
            
            switch emailverificationType {
            case .signUp:
                
                if Auth.auth().currentUser?.isEmailVerified == true {
                    timer?.invalidate()
                    isVerified = true
                }
            case .changeEmail:
                if Auth.auth().currentUser?.isEmailVerified == true , let verifiedEmail = Auth.auth().currentUser?.email, verifiedEmail == email {
                    timer?.invalidate()
                    isVerified = true
                }
            }
        }
    }
    
    private func sendVerificationLink() async throws{
        
       
        do{
                switch emailverificationType {
            case .signUp:
                        try await session.sendVerificationEmail()
            case .changeEmail:
                        try await session.verifyBeforeUpdateEmail(email: email)
                    
            }
        }catch{
            throw error
        }
    }
    
    private func handleEmailNotVerified() {
        isVerified = false
        timeOver = true
        
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    private func onEmailVerified() {
        // Implement what you want to do when the email is verified
        print("Email verified")
    }
    
    
}



