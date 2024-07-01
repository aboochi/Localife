//
//  EmailAuthTabView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/17/24.
//

import SwiftUI

struct EmailAuthTabView: View {
    @State var selection = 1
    @Environment(\.dismiss) var dismiss
    @State var email: String = ""

    var body: some View {
        ZStack{
            
           
            
            VStack{
                Spacer()
                
                if selection == 0{
                    SignUpEmailView(  email: $email, signUpType: .signUp)
                }else{
                    SignInEmailView(  email: $email)
                }
                


                
                
                Spacer()
                
                tabSelection
                
                
                
            }
            VStack(){
                HStack{
                    Button(action: {dismiss()}, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 25, weight: .light))
                            .foregroundColor(.black)
                            .padding()
                        
                    })
                    Spacer()
                }

              Spacer()
            }

        }
        
    }
    
    @ViewBuilder
    var tabSelection: some View{
        
  
            
            HStack {
                Text( selection == 0 ?  "Already have an account?" : "Don't have an account yet?")
                
                Button {
                
                    if selection == 0{
                        selection = 1
                        
                    }else{
                        selection = 0
                    }
                } label: {
                    Text(selection == 0 ? "Log in" : "Sign up")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                
            }
            .padding([.top, .bottom], 50)
            
        
    }
    
        
}

