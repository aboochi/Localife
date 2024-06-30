//
//  MessageShareImageView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/16/24.
//

import SwiftUI

struct MessageShareImageView: View {
    
    @EnvironmentObject var viewModel: ChatViewModel
    @FocusState var focus: Bool
    
    let pickerId: String
    
    var body: some View {
        
        ScrollView(showsIndicators: false){
            VStack{
                if let imagePickerViewModel = viewModel.imagePickerViewModels[pickerId] {
                    SelectedMediaScrollView(viewModel: imagePickerViewModel) { index in
                        OnTapGestureModifier {
                            imagePickerViewModel.displayIndex = index
                        }
                    }
                    .padding(.horizontal)
                    
                }
                
                ZStack{
                    Rectangle()
                        .fill(.white)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                    if let imagePickerViewModel = viewModel.imagePickerViewModels[pickerId] {
                        SelectedMediaDisplayView(viewModel: imagePickerViewModel)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                    }
                    
                }
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
                
                TextField("Write a caption...", text: $viewModel.caption)
                    .focused($focus)
                    .padding()
                    .frame(height: 40)
                    .background(Capsule().fill(.gray.opacity(0.1)))
                    .overlay(
                        Capsule()
                            .stroke(.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                
                Spacer()
            }
        }
        .onTapGesture {
            focus = false
        }
        
        
        .navigationBarItems(trailing:
                                
        Button(action: {
            Task{
                viewModel.subscribeTocompletedUploadingSteps(id: pickerId)
                try await viewModel.sendMesssage(id: pickerId)
            }
            
        }, label: {
            Text("Send")
                .font(.system(size: 16, weight: .bold))
        })
        )
    }
}


