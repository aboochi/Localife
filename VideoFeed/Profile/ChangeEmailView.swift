//
//  ChangeEmailView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/6/24.
//



import SwiftUI
import FirebaseAuth


struct ChangeEmailView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @State var email: String = ""
    @State var confirmedEmail: String = ""
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    @State var errorMessage = ""
    @State var emailMatched = false
    @Binding var isVerified: Bool 
    @State var showVerificationView: Bool = false



    var body: some View {
        VStack{
            
            TextField("New Email", text: $email)
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
                
                
          
            TextField("Confirm Email", text: $confirmedEmail)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($focus, equals: .confirmedPassword)
                .submitLabel(.go)
                .onChange(of: confirmedEmail, { oldValue, newValue in
                    emailMatched  = (email == confirmedEmail)
                })
                
                .onSubmit {
                    Task{
                        do{
                            try await session.verifyBeforeUpdateEmail(email: email)
                            print("Update email")
                            session.userViewModel.dbUser?.email = email
                            

                        } catch{
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .overlay {
                    if emailMatched{
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
                    
                    
                   
                        
                        if emailMatched{
                            
                            showVerificationView = true
                        }
                        
                        if isVerified{
                             
                          session.userViewModel.dbUser?.email = email
                        }
                    
                    
 
                }
                

            }, label: {
                Text("Change Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background(!emailMatched ? Color.blue.opacity(0.5) : Color.blue)
                    .cornerRadius(10)
            })
            .disabled(!emailMatched)


            if showVerificationView{
                
                EmailVerificationView(isVerified: $isVerified, emailverificationType: .changeEmail, email: email, errorMessage: $errorMessage)

            }
         
        }
        .padding()
        .onChange(of: focus) { oldFocus ,newFocus in
            if self.errorMessage != "" && newFocus != nil && oldFocus == nil{
                self.email = ""
                self.confirmedEmail = ""
                self.errorMessage = ""
            }
        }
        
        
    }
    
    func passwordMatchCheck() {
        
        if email != confirmedEmail{
            errorMessage = "Emails Don't Match!"
            
        }
        
    }
}

