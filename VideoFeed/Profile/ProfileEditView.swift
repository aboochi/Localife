//
//  ProfileEditView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/9/24.
//

import SwiftUI

struct ProfileEditView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ProfileViewModel
    @State var screenWidth = UIScreen.main.bounds.width
    @State var username: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var bio: String = ""
    @State var selectedImage: UIImage?
    @State var presentImagePicker = false
    @State var showEditImageOption: Bool = false
    @State var edit: Bool = false


    

    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .leading){
                
                VStack(alignment: .leading){
                    
                    
                    ZStack{
                        AvatarView(photoUrl: session.dbUser.photoUrl, username: session.dbUser.username, size: 100)
                        if let selectedImage = selectedImage{
                            
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(20)
                                .onAppear{
                                   // HapticManager.shared.generateFeedback(of: .notification(type: .success))
                                    
                                }
                            
                            
                        }
                    }
                    
                    
                    Button {
                        if session.dbUser.photoUrl != nil{
                            
                            showEditImageOption = true
                            
                        }else{
                            presentImagePicker = true
                        }
                    } label: {
                        Text("Edit profile picture")
                            .foregroundColor(.blue)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.vertical, 3)
                    }

                   
                }
                .padding(.bottom, 30)
                
                NavigationLink {
                    
                    ProfileEditCellView(itemCategory: .username)
                        .environmentObject(session)
                        .environmentObject(viewModel)
                    
                } label: {
                    profileItem(title: "Username", text: session.dbUser.username ?? "")
                    
                  

                }
                
                NavigationLink {
                    
                    ProfileEditCellView(itemCategory: .name)
                        .environmentObject(session)
                        .environmentObject(viewModel)
                    
                } label: {
                    
                    profileItem("Optional", title: "Name" , text: "\(session.dbUser.firstName ?? "") \(session.dbUser.lastName ?? "")")
                   
                }
                
                NavigationLink {
                    
                    ProfileEditCellView(itemCategory: .bio)
                        .environmentObject(session)
                        .environmentObject(viewModel)
                    
                } label: {
                    profileItem("Optional", title: "Bio" , text: session.dbUser.bio ?? "")
                   
                }
              
            }
        }
        .padding()
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        
        
        .fullScreenCover(isPresented: $presentImagePicker, content: {
            ProfileImagePickerView(selectedImage: $selectedImage)
        })
        
        .onChange(of: edit, { oldValue, newValue in
            if newValue{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                    presentImagePicker = true
                    edit = false
                }
            }
        })
        
        
        .sheet(isPresented: $showEditImageOption) {
            
            EditProfileImageOptionView(showView: $showEditImageOption, presentImagePicker: $presentImagePicker, selectedImage: $selectedImage, edit: $edit)
                .presentationDetents([.height(150)])
        }
    
    }
    
    @ViewBuilder
    func profileItem(_ placeholder: String = "", title: String, text:  String) -> some View{
        HStack{
            Text(title)
                .font(.system(size: 16, weight: .regular))
            Spacer()
            
            HStack(){
                Text(text)
                    .padding(.horizontal, 10)
                Spacer()
            }
            .frame(width: screenWidth * 0.65, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1 / 3)
                        .opacity(0.6)
                )
        }
        .foregroundColor(.black)
    }
    
    
}

struct EditProfileImageOptionView:  View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding var showView: Bool
    @Binding var presentImagePicker: Bool
    @Binding var selectedImage: UIImage?
    @Binding var edit: Bool

    
    var body: some View {
        
        VStack{
            
            Button {
                showView = false
                edit = true
                
            } label: {
                option(text: "Edit", color:  .black)

            }
            
            Button {
                Task{
                    try await UserManager.shared.deletePhotoUrl(uid: session.dbUser.id)
                    session.dbUser.photoUrl = nil
                    selectedImage = nil
                    showView = false

                    
                }
            } label: {
                option(text: "Delete", color:  .red)

            }


        }
        .padding()
    }
    
    
    @ViewBuilder
    func option(text: String, color: Color = .black) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .padding()
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .overlay(
                Capsule()
                    .stroke(Color.black, lineWidth: 1)
            )
            
           
    }
}
