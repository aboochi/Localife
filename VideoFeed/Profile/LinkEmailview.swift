//
//  LinkEmailview.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/7/24.
//

import SwiftUI

struct LinkEmailView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    @State var errorMessage = ""
    @State var passwordsMatched = false
    


    var body: some View {
        VStack{
            
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
                    self.focus = .confirmedPassword
                }
                
            
            SecureField("Confirm password", text: $confirmedPassword)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .focused($focus, equals: .confirmedPassword)
                .submitLabel(.go)
                .onChange(of: confirmedPassword, { oldValue, newValue in
                    passwordsMatched = (password == confirmedPassword) && password.count > 5
                })
                
                .onSubmit {
                    Task{
                        do{
                            try await session.linkEmail(email: email, password: password)
                            return
                        }catch{
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .overlay {
                    if passwordsMatched{
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
                        do{
                            try await session.linkEmail(email: email, password: password)
                            return
                        }catch{
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                

            }, label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background((password.count < 6 || confirmedPassword.count < 6 || email.count < 1) ? Color.blue.opacity(0.5) : Color.blue)
                    .cornerRadius(10)
            })
            .disabled((password.count < 6 || confirmedPassword.count < 6 || email.count < 1))



            
        }
        .padding()
        .onChange(of: focus) { oldFocus ,newFocus in
            if self.errorMessage != "" && newFocus != nil && oldFocus == nil{
                self.password = ""
                self.confirmedPassword = ""
                self.errorMessage = ""
            }
        }
        
        
    }
    
    func passwordMatchCheck() {
        
        if password != confirmedPassword{
            errorMessage = "Passwords Don't Match!"
            
        }
        
    }
}

