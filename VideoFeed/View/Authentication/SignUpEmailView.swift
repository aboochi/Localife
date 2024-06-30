//
//  SignUpEmailView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/17/24.
//

import SwiftUI

enum SignUpTypeEnum{
    case signUp
    case link
}

enum FocusableField: Hashable {
  case email
  case password
  case confirmedPassword
  case message
  case username
}

struct SignUpEmailView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    @State var errorMessage = ""
    @State var passwordsMatched = false
    @Binding var email: String
    @State var showVerificationAwaitview: Bool = false
    @State var isVerified: Bool = false
    let signUpType: SignUpTypeEnum
    

    var body: some View {
        VStack{
            
            TextField("Email", text: $email)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Capsule().fill(Color.gray.opacity(0.1)))
                .overlay(
                    Capsule()
                        .stroke(.gray, lineWidth: 0.5)
                )
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($focus, equals: .email)
                .submitLabel(.next)
                .onSubmit {
                  self.focus = .password
                }
                
                
                
            
            SecureField("Password", text: $password)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Capsule().fill(Color.gray.opacity(0.1)))
                .overlay(
                    Capsule()
                        .stroke(.gray, lineWidth: 0.5)
                )
                .focused($focus, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                    self.focus = .confirmedPassword
                }
                
            
            SecureField("Confirm password", text: $confirmedPassword)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Capsule().fill(Color.gray.opacity(0.1)))
                .overlay(
                    Capsule()
                        .stroke(.gray, lineWidth: 0.5)
                )
                .focused($focus, equals: .confirmedPassword)
                .submitLabel(.go)
                .onChange(of: confirmedPassword, { oldValue, newValue in
                    passwordsMatched = (password == confirmedPassword) && password.count > 5
                })
                
                .onSubmit {
                    Task{
                        try await signUp()
                    }
                }
                .overlay {
                    if passwordsMatched && password.count >= 8{
                        HStack{
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundColor(.green)
                                .padding()
                                

                        }
                    }
                }
            
            
            if !errorMessage.isEmpty {
              VStack {
                Text(errorMessage)
                  .foregroundColor(Color(UIColor.systemRed))
              }
            }
            
            Button(action: {
                passwordMatchCheck()
                focus = nil
                if errorMessage == ""{
                    Task{
                        try await signUp()
                    }
                }
                

            }, label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background(Capsule().fill((password.count < 8 || confirmedPassword.count < 8 || email.count < 1) ? Color.blue.opacity(0.5) : Color.blue))
                    .cornerRadius(10)
            })
            .disabled((password.count < 8 || confirmedPassword.count < 8 || email.count < 1))


            Text("Password must be at least 8 characters long.")
                .foregroundColor(Color(UIColor.darkGray))
                .font(.system(size: 14, weight: .regular))
                .padding(.horizontal, 10)
            
            
            if  showVerificationAwaitview {
                
                EmailVerificationView(isVerified: $isVerified, emailverificationType: .signUp, email: "", errorMessage: $errorMessage)
                    
                    .onAppear{
                        
                        isVerified = true   //this is to test purpose to skip email verification
                    }
            }
                

            
        }
        .padding()
        .onChange(of: focus) { oldFocus ,newFocus in
            if self.errorMessage != "" && newFocus != nil && oldFocus == nil{
                self.password = ""
                self.confirmedPassword = ""
                self.errorMessage = ""
            }
        }
        
        
        .onChange(of: errorMessage) { oldValue, newValue in
            
            if !newValue.isEmpty{
                HapticManager.shared.generateFeedback(of: .notification(type: .error))
            }

        }
        
        .onChange(of: isVerified) { oldValue, newValue in
            if isVerified{
                Task{
                    try await session.updateAuthentication( authProviderOption: .email)
                    
                }
            }
        }
        
        
    }
    
    func passwordMatchCheck() {
        
        if password != confirmedPassword{
            errorMessage = "Passwords Don't Match!"
            
        }
        
    }
    
    func signUp() async throws{
        
        do{
            
            switch signUpType{
                
            case .signUp:
                try await session.signUpEmail(email: email, password: password)
                showVerificationAwaitview = true
            case .link:
                try await session.linkEmail(email: email, password: password)
                showVerificationAwaitview = true
            }
     
         
            }catch{
            errorMessage = error.localizedDescription
        }
    }
}

