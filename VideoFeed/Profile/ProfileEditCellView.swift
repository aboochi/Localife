//
//  ProfileUsernameEditView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/10/24.
//

enum ProfileItemEnum: String{
    case username = "Username"
    case name = "Name"
    case bio = "Bio"
}

import SwiftUI

struct ProfileEditCellView: View {
    
    @Environment(\.dismiss)  var dismiss
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ProfileViewModel
    @State var screenWidth = UIScreen.main.bounds.width
    @State var username: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var bio: String = ""
    @State var usernameValidity: UsernameValidationError = .initial
    let itemCategory: ProfileItemEnum
    @FocusState var focusState: Bool
    @State var updated: Bool =  false
    @State var showUnsavedAlert: Bool = false
    
    
    var body: some View {
        ZStack{
            VStack{
                switch itemCategory {
                case .username:
                    textField(title: "Username", text: $username)
                    Text(usernameValidity.rawValue)
                        .foregroundColor(.red)
                    
                case .name:
                    textField(title: "First Name", text: $firstName)
                    textField(title: "Last Name", text: $lastName)
                    
                case .bio:
                    textField(title: "Bio", text: $bio)
                    
                }
                
                Spacer()
                
            }
            
            if updated{
                
                Text(itemCategory.rawValue )
                +
                Text(" successfully updated")
            }
        }
        .padding()
        .navigationBarItems(leading: backButton, trailing: saveButton)
        .navigationBarBackButtonHidden()
        .onAppear{
            
            focusState = true
            username = session.dbUser.username ?? ""
            firstName = session.dbUser.firstName ?? ""
            lastName = session.dbUser.lastName ?? ""
            bio = session.dbUser.bio ?? ""
        }
        .onChange(of: username) { oldValue, newValue in
            username = username.lowercased()
            usernameValidity = .initial
        }
        .onChange(of: updated) { oldValue, newValue in
            if newValue{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
                    dismiss()
                }
            }
        }
        
        .alert(isPresented: $showUnsavedAlert) {
            Alert(
                title: Text("Unsaved Changes"),
                message: Text("You have unsaved changes. Would you like to save them or discard them?"),
                primaryButton: .default(Text("Keep Editing"), action: {
                    
                }),
                secondaryButton: .destructive(Text("Discard Changes"), action: {
                    
                    dismiss()
                })
            )
        }
        
    }
    
    
    @ViewBuilder
    
    var saveButton: some View{
        
        Button {
            
            switch itemCategory {
            case .username:
                Task{
                    
                    do{
                        usernameValidity = viewModel.validateUsername(username)
                        if usernameValidity == .valid{
                            let result = try await viewModel.isUsernameAvailable(username: username)
                            if !result{
                                usernameValidity = .notAvailable
                            }
                        }
                        if usernameValidity == .valid{
                            try await viewModel.updateUsername(username: username)
                            session.userViewModel.dbUser?.username = username
                            viewModel.user.username = username
                            updated = true
                            
                        }
                        
                    }catch{
                        
                    }
                }
            case .name:
                Task{
                    
                    do{
                        try await viewModel.updateFirstName(firstName: firstName)
                        try await viewModel.updateLastName(lastName: lastName)
                        session.userViewModel.dbUser?.firstName = firstName
                        session.userViewModel.dbUser?.lastName = lastName
                        viewModel.user.firstName = firstName
                        viewModel.user.lastName = lastName
                        updated = true
                        
                    }catch{
                        print("error updating name: \(error)")
                    }
                    
                }
                
            case .bio:
                Task{
                    
                    do{
                        try await viewModel.updateBio(bio: bio)
                        session.userViewModel.dbUser?.bio = bio
                        viewModel.user.bio = bio
                        updated = true
                    }
                    
                }
                
            }
            
            
        } label: {
           Text("Save")
                .foregroundColor(.blue)
                .font(.system(size: 18, weight: .semibold))
        }
    }
    
    @ViewBuilder
    var backButton: some View{
        
        Button {
            
            var saved = false
            switch itemCategory {
            case .username:
                saved = session.dbUser.username == username
            case .name:
                saved = (session.dbUser.firstName == firstName &&  session.dbUser.lastName == lastName)

            case .bio:
                saved = session.dbUser.bio == bio

            }
            if saved {
                dismiss()
            }else{
                showUnsavedAlert = true
            }
            
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundColor(.blue)
                .font(.system(size: 18, weight: .semibold))

            
        }

    }
    
  
    @ViewBuilder
    func textField(_ placeholder: String = "", title: String, text:  Binding<String>) -> some View{
        
        HStack{
            Text(title)
                .font(.system(size: 16, weight: .regular))

            Spacer()
            TextField(placeholder, text: text)
                .focused($focusState)
                .frame(width: screenWidth * 0.65, height: 40)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1 / 3)
                        .opacity(0.6)
                )
            
        }
    }
}


