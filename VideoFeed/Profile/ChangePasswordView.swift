//
//  ChangePasswordView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/6/24.
//

import SwiftUI



struct ChangePasswordView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    @State var errorMessage = ""
    @State var passwordsMatched = false
    @Binding var passwordChanged: Bool
    @State var success: Bool = false


    var body: some View {
        VStack{
            
            
            Text("Password Successfully Changed")
                .foregroundColor(success ? .blue : .clear)
                .font(.system(size: 16, weight: .semibold))
                .frame(height: 20)
        
            SecureField("New Password", text: $password)
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
                        try await changePassword()
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
                        try await changePassword()
                    }
                }
                

            }, label: {
                Text("Change Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background((password.count < 6 || confirmedPassword.count < 6 ) ? Color.blue.opacity(0.5) : Color.blue)
                    .cornerRadius(10)
            })
            .disabled((password.count < 6 || confirmedPassword.count < 6 ))


            
           
                

            
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
    
    func changePassword() async throws{
        
        do{
            try await session.updatePassword(password: password)
            print("password changed successfully")
            success = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){
                passwordChanged = true
            }
          
        }catch{
            errorMessage = error.localizedDescription
        }
    }
}

