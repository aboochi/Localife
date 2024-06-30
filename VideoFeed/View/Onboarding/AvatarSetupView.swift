//
//  AvatarSetupView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/16/24.
//

import SwiftUI
import Kingfisher

struct AvatarSetupView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @State var presentImagePicker: Bool = false
    @Binding var selection: Int
    @State var selectedImage: UIImage?


    var body: some View {
        VStack{
            
            if  session.dbUser.photoUrl != nil || selectedImage != nil{
                ZStack{
                if let phtoURL = session.dbUser.photoUrl, let url = URL(string: phtoURL){
                   
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(20)
                            .onAppear{
                                // HapticManager.shared.generateFeedback(of: .notification(type: .success))
                                
                            }
                    }
                    
                    
                    if let selectedImage = selectedImage{
                        
                        
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(20)
                            .onAppear{
                                HapticManager.shared.generateFeedback(of: .notification(type: .success))
                                
                            }
                        
                    }
                }
                .frame(width: 150, height: 150)
                
                VStack{
                    
                    Button(action: {
                        presentImagePicker = true
                    }, label: {
                        Text("Edit")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(.black.opacity(0.5)))
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.0), lineWidth: 1)
                            )
                           
                    })
                    
                    Button(action: {
                        Task{
                            try await UserManager.shared.deletePhotoUrl(uid: session.dbUser.id)
                            session.dbUser.photoUrl = nil
                            selectedImage = nil
                            
                        }
                    }, label: {
                        Text("Remove")
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(.white.opacity(0.7)))
                            .overlay(
                                Capsule()
                                    .stroke(.black.opacity(0.3), lineWidth: 0)
                            )
                            
                    })
                    
                    
                   
                }
                .frame(width: 150)
                .padding()

            
                
                
            }else{
                
                Button(action: {
                    presentImagePicker = true
                }, label: {
                    Text("Select a Profile Photo")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(.black.opacity(0.5)))
                        .padding()
                })
            }
        }
        .fullScreenCover(isPresented: $presentImagePicker, content: {
            ProfileImagePickerView(selectedImage: $selectedImage)
        })
        .onChange(of: selectedImage) { oldValue, newValue in
            print(" selected image changed >>>>>>>>>>>>>>. \(selectedImage)")
        }
        
    }
    
    
    func goNextStep(){
        var stage = session.onBoardingStage.rawValue
        if stage < 3{
            withAnimation(.easeInOut(duration: 0.5)){
                stage += 1
                let newStage = OnboaringStage(rawValue: stage)
                session.onBoardingStage = newStage ?? .done
            }
            Task{
                try await session.updateUserOnboardingState(onBoardingState:stage)
                HapticManager.shared.generateFeedback(of: .notification(type: .success))
                
            }
        }
    }
    
}

