//
//  ReAuthenticationView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/6/24.
//

import SwiftUI



struct ReAuthenticationView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @State var email: String = ""
    @State var password: String = ""
    @FocusState private var focus: FocusableField?
    @State private var errorMessage: String = ""
    @Binding var reAuthenticationConfirmed: Bool
    @Binding var isVerified: Bool
    @Binding var reLoginAfterEmailChange: Bool
    @State var forgotPassword: Bool = false




    var body: some View {
        VStack{
            
            switch isVerified{
            case true:
                
                Text("your email was successfully changed.")
                Text("Please sign in with your new email to continue")
                
            case false:
                
                Text("This operation is sensitive and requires recent authentication. Log in again before retrying this request.")

            }
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($focus, equals: .email)
                .submitLabel(.next)
                .onSubmit {
                  self.focus = .password
                }
                
                
                
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .focused($focus, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                    
                    self.focus = nil
                    Task{
                        
                        switch isVerified{
                        case true:
                            try await signIn()
                        case false:
                            try await reAuthenticate()
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
                Task{
                    
                    switch isVerified{
                    case true:
                        try await signIn()
                    case false:
                        try await reAuthenticate()
                    }
                    
                }
            }, label: {
                Text(isVerified ? "Sign In": "Verify")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background((password.count < 1 || email.count < 1) ? Color.blue.opacity(0.5) : Color.blue)
                    .cornerRadius(10)
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
                }
            }

            
 
            
        }
        .padding()
        .onChange(of: focus) { oldFocus ,newFocus in
            if self.errorMessage != "" && newFocus != nil && oldFocus == nil{
                self.password = ""
                self.errorMessage = ""
            }
        }
        
        .sheet(isPresented: $forgotPassword, content: {
            
            ResetPasswordView(email: $email, resetPasswordType: .outside)
                .presentationDetents([.medium])
        })
    }
    
    
    func reAuthenticate() async throws{
        
        do{
            try await session.reAuthenticate(email: email, password: password)
            reAuthenticationConfirmed = true

        }catch{
            errorMessage = error.localizedDescription
        }
    }
    
    
    func signIn() async throws{
        
        do{
            try await session.signInEmail(email: email, password: password)
            reAuthenticationConfirmed = true
            reLoginAfterEmailChange = true

        }catch{
            errorMessage = error.localizedDescription
        }
    }
    
    
}


