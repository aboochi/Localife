//
//  EditPostCaptionView.swift
//  Localife
//
//  Created by Abouzar Moradian on 6/25/24.
//

import SwiftUI

struct EditPostCaptionView: View {
    
    @Environment(\.dismiss)  var dismiss
    @StateObject var viewModel: ProfileViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding  var showOptions: Bool
    let postId: String
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    @FocusState private var focus: Bool
    @Binding var caption: String
    @State var showSuccessMessage: Bool = false
    
    var body: some View {
        VStack{
            
            
            
            headerBar
            
            if showSuccessMessage{
                
                successMessage
                    .padding(.vertical, screenHeight/4 )
            }else{
                captionSection
                    .padding()
                
            }
            
            Spacer()
                
                
            
            
        }
        .onAppear{
            focus = true
        }
        .onTapGesture {
            focus = false
        }
    }
    
    
    
    @ViewBuilder
    var captionSection: some View{
        
        VStack{
            TextEditor(text: $caption)
                .font(.system(size: 15, weight: .semibold))
                .focused($focus)
                .frame(height: screenWidth * 0.4)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .stroke(.gray, lineWidth: 1)
                )
                .overlay(
                    Group{
                        if caption.isEmpty{
                            Text("Write a caption...")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 5)
                                .allowsHitTesting(false)
                        }
                    }
                    ,alignment: .topLeading
                )
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 15)

    }
    
    @ViewBuilder
    var leadingButton: some View{
        
        Button {
            showOptions = false
            dismiss()
            
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.blue)
        }

        
    }
    
    @ViewBuilder
    var trialingButton: some View{
        
        Button {
            
            Task{
                do{
                    focus = false
                    try await viewModel.editCaption(caption: caption, postId: postId)
                    showSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
                        showOptions = false
                        dismiss()
                    }
                    
                    
                }catch{
                    showOptions = false
                    dismiss()
                }
            }
            
        } label: {
            Text("Done")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
        }

        
    }
    
    
    @ViewBuilder
    var successMessage: some View{
        
        Text("Caption successfully updated")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .padding()
            .background(
                Capsule().fill(.white)
                    .shadow(radius: 10)
            )
    }
    
    
    
    @ViewBuilder
    var title: some View{
        
        Text("Edit Caption")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.black)
    }
    
    @ViewBuilder
    var headerBar: some View{
        
        HStack{
            
            leadingButton
            Spacer()
            title
            Spacer()
            trialingButton
        }
        .padding()
    }
}

 
