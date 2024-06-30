//
//  SignInEmailView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//

import SwiftUI



struct SignInEmailView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @State var password: String = ""
    
    @Binding var email: String
    @FocusState private var focus: FocusableField?
    @State private var errorMessage: String = ""
    @State var forgotPassword: Bool = false
    @State var isVerified: Bool = false
    @State var showVerificationAwaitview: Bool = false



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
                    
                    self.focus = nil
                    Task{
                        
                        try await signIn()

                        
                    } 
                }
            
            if !errorMessage.isEmpty {
              VStack {
                Text(errorMessage)
                  .foregroundColor(Color(UIColor.systemRed))
              }
            }
            
            Button(action: {
                Task{
                    self.focus = nil
                    try await signIn()
                    
                }
            }, label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background( Capsule().fill((password.count < 1 || email.count < 1) ? Color.blue.opacity(0.5) : Color.blue))
                    
            })
            .disabled((password.count < 1 || email.count < 1))

            HStack{
                
                Spacer()
                Button {
                    forgotPassword = true
                } label: {
                    Text("Forgot my password!")
                        .foregroundColor(.blue)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.horizontal, 10)
                }
            }
            
      
            if  showVerificationAwaitview {
                
                EmailVerificationView(isVerified: $isVerified, emailverificationType: .signUp, email: "", errorMessage: $errorMessage)
            }
            
            
        }
        
        .sheet(isPresented: $forgotPassword, content: {
            
            ResetPasswordView(email: $email, resetPasswordType: .outside)
                .presentationDetents([.medium])
        })
        
        
        .padding()
        .onChange(of: focus) { oldFocus ,newFocus in
            if self.errorMessage != "" && newFocus != nil && oldFocus == nil{
                self.password = ""
                self.errorMessage = ""
            }
        }
        
        .onChange(of: isVerified) { oldValue, newValue in
            Task{
                try await session.updateAuthentication(authProviderOption: .email, updateAll: true)
            }
        }
        
        .onChange(of: errorMessage) { oldValue, newValue in
            
            if !newValue.isEmpty{
                HapticManager.shared.generateFeedback(of: .notification(type: .error))
            }

        }
    }
    
    func signIn() async throws {
        
        do{
            try await session.signInEmail(email: email, password: password)
            isVerified = try await session.checkEmailVerification()
            if isVerified{
                try await session.updateAuthentication(authProviderOption: .email, updateAll: true)
            }else{
                showVerificationAwaitview = true
            }
            return
        }catch{
            errorMessage = error.localizedDescription
        }
    }
}

