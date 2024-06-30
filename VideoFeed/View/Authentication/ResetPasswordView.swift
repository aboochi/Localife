//
//  ResetPasswordView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/7/24.
//

enum ResetPasswordType{
    case outside
    case inside
}

import SwiftUI

struct ResetPasswordView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @State var linkSent: Bool = false
    @State var forgotPassword: Bool = false
    @State var newLinkSent: Bool = false
    @FocusState private var focus: FocusableField?
    @State var errorMessage: String = ""
    @Binding var email: String
    let resetPasswordType: ResetPasswordType
    
 
    var body: some View {
        
        VStack{
            
            if resetPasswordType == .outside{
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
                        .submitLabel(.go)
                        .onSubmit {
                            self.focus = nil
                            Task{
                                try await sendLink()
                            }
                        }
                    
                    VStack{
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.red)
                    }
                    .frame(height: 20)
                    
                }
            }
            
            HStack{
                
                Spacer()
         
               
            }
               
                Button {
                    self.focus = nil
                    Task{
                        try await sendLink()
                    }
                    
                } label: {
                    
                    Group{
                        if linkSent{
                            Text("Link Sent")
                            
                        }else{
                            if newLinkSent{
                                Text("Send me a reset link again")
                            }else{
                                Text("Send me a reset link")
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background( Capsule().fill( email.count < 1 || linkSent ? Color.blue.opacity(0.5) : Color.blue))
                    .cornerRadius(10)
                }

                
                
               
             if  newLinkSent{
                
                VStack{
                   
                        Text("We sent a link to your email. Please click on the link to reset your password")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.blue)
                   
                 
                }
            }
            
           Spacer()
        }
        .padding()
        .padding(.top, 30)
        .onAppear{
            if resetPasswordType == .outside{
                focus = .email
            }
        }
        .onChange(of: linkSent) { oldValue, newValue in
            if newValue{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5){
                    linkSent = false
                }
            }
        }
        .onChange(of: focus) { oldValue, newValue in
            if focus != nil{
                errorMessage = ""
            }
        }
    }
    
    func sendLink() async throws{
        do{
            try await session.resetPassword(inputEmail: email)
            
            newLinkSent = true
            linkSent = true
        }catch{
            errorMessage = error.localizedDescription
        }
    }
}


