//
//  MessageContextMenu.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/18/24.
//

import SwiftUI

struct MessageContextMenu: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ChatViewModel
    @Binding var showContextMenu: Bool
    let selectedMessage: Message
    let selectedMessageGeometry: GeometryProxy
    let screenWidth = UIScreen.main.bounds.width
    var midX: CGFloat {
        selectedMessageGeometry.frame(in: .global).midX
    }
    var midY: CGFloat {
        selectedMessageGeometry.frame(in: .global).midY
    }
    
    
    
    var ownAccount: Bool {
        return selectedMessage.ownerId == session.dbUser.id
    }
    

    
    var body: some View {
        
        VStack{
            MessageCellView(message: selectedMessage, otherUser: viewModel.otherUser, scrollToId: .constant("") )
                .onTapGesture {
                    showContextMenu = false
                }
            
                .overlay(
                    customMenu
                        .offset(CGSize(width: 0, height: 230))
                    , alignment: ownAccount ? .bottomTrailing: .bottomLeading
                   
                )
                .overlay(
                    MessageReactionBar(ownAccount: ownAccount, message: selectedMessage, showContextMenu: $showContextMenu)
                        .offset(CGSize(width: 0, height: -63))
                    , alignment: ownAccount ? .topTrailing: .topLeading
                )
                .position(x: midX ,
                          y: getMidYPosition() )
                
      
        }
       
    }
    
    func getMidYPosition() -> CGFloat{
        
        if midY > 450{
            return 450
        }else if midY < 200{
            return 200
        }else{
            return midY
        }
        
    }
    
  
    var customMenu: some View{
        
        
        VStack(spacing: 10) {
        
            Button(action: {
                viewModel.repliedMessage = selectedMessage
                HapticManager.shared.generateFeedback(of: .impact(style: .medium), intensity: .strong)
                showContextMenu = false
                
            }) {
                HStack {
                    Text("Reply")
                    Spacer() // Adds space between text and image
                    Image(systemName: "arrow.turn.up.left")
                }
            }
            
            Divider()

            
            Button(action: {
                viewModel.showSharePostVew = true
                HapticManager.shared.generateFeedback(of: .impact(style: .medium), intensity: .strong)
                showContextMenu = false
               
            }) {
                HStack {
                    Text("Forward")
                    Spacer() // Adds space between text and image
                    Image(systemName: "arrow.turn.up.right")
                }
            }
            
            Divider()

           
//            Button(action: {
//                
//                
//            }) {
//                HStack {
//                    Text("Copy")
//                    Spacer() // Adds space between text and image
//                    Image(systemName: "doc.on.doc")
//                }
//            }
//            
//            Divider()

            
           
                Button(action: {
                    
                    if selectedMessage.ownerId == session.dbUser.id && !selectedMessage.text.isEmpty{
                        viewModel.editedMessage = selectedMessage
                        HapticManager.shared.generateFeedback(of: .impact(style: .medium), intensity: .strong)
                        showContextMenu = false
                    }
                    
                }) {
                    HStack {
                        Text("Edit")
                        Spacer() // Adds space between text and image
                        Image(systemName: "pencil.tip.crop.circle")
                        
                    }
                }
                .foregroundColor((selectedMessage.ownerId == session.dbUser.id && !selectedMessage.text.isEmpty) ? .black : .gray.opacity(0.3))
                .disabled(!(selectedMessage.ownerId == session.dbUser.id && !selectedMessage.text.isEmpty))
               
                
                
                Divider()
            
            
            
            Button(action: {
                
                Task{
                    try await selectedMessage.isHidden ?  viewModel.unHide(message: selectedMessage):viewModel.hide(message: selectedMessage)
                    HapticManager.shared.generateFeedback(of: .impact(style: .medium), intensity: .strong)
                    showContextMenu = false
                }
            
            }) {
                HStack {
                    Text(selectedMessage.isHidden ? "Visible": "Hidden")
                    Spacer() // Adds space between text and image
                    Image(systemName: selectedMessage.isHidden ? "eye" :  "eye.slash")
                }
            }
            

           
                
                Divider()
                
                Button(action: {
                    Task{
                        try await viewModel.delete(message: selectedMessage)
                        HapticManager.shared.generateFeedback(of: .impact(style: .medium), intensity: .strong)
                        showContextMenu = false
                    }
                    
                }) {
                    HStack {
                        Text("Delete")
                            .foregroundColor( (selectedMessage.ownerId == session.dbUser.id) ? .red : .black) // Set text color to red
                        
                        
                        Spacer() // Adds space between text and image
                        Image(systemName: "trash")
                            .foregroundColor( (selectedMessage.ownerId == session.dbUser.id) ? .red : .black) // Set text color to red

                    }
                }
                .foregroundColor((selectedMessage.ownerId == session.dbUser.id ) ? .black : .gray.opacity(0.3))
                .disabled(!(selectedMessage.ownerId == session.dbUser.id ))
            
            
        }
        .padding()
        .foregroundColor(.black)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, ownAccount ? 10 : 40 )
        .frame(width: screenWidth * 0.65)
        .padding(.top, 5)
    }
    
    
    
    

    
    
    
    
    
    
    
}


