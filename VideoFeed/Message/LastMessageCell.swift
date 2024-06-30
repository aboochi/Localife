//
//  LastMessageCell.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/15/24.
//

import SwiftUI

struct LastMessageCell: View {
    @EnvironmentObject var viewModel: MessageViewModel
    @EnvironmentObject var session: AuthenticationViewModel

    let chat: Message
    let currentUser: DBUser
    var ownAccount: Bool{
        chat.ownerId == currentUser.id
    }
    var otherId: String {
        return chat.ownerId == currentUser.id ? chat.recipientId : chat.ownerId
    }
    var username: String {
        if let otherUser = chat.user{
            return otherUser.username ?? "Unknown"
        } else{
            return !ownAccount ? chat.ownerUsername : chat.recipientUsername
        }
    }
    let screenWidth = UIScreen.main.bounds.width
    var phtoUrl: String? {
        
        if let otherUser = chat.user{
            return otherUser.photoUrl
        }else{
            return !ownAccount  ? chat.ownerPhotoUrl : chat.recipientPhotoUrl
        }
    }
    
    var body: some View {
       
        HStack(alignment: .top){
            
            HStack(alignment: .center){
                AvatarView(photoUrl: phtoUrl, username: username, size: 50)
                
                VStack(alignment: .leading){
                    Text(username)
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.bottom, 3)
                   
                    if !session.dbUser.blockedIds.contains(otherId){
                        chatContent
                    }else{
                        messageTypeIcon(text: "Bloked")
                    }
                    
                   
                }
                
            }
            
            Spacer()
            VStack(alignment: .trailing){
                Text(TimeFormatter.shared.lastChatformatter(chat.time))
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.gray)
                    .font(.caption)
                
                if let unreadMessages = viewModel.unreadChats[otherId] , unreadMessages.messagesNumber > 0{
                    Text("\(unreadMessages.messagesNumber)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.blue))
                }
            }
            
        }
        .padding()
        
        .overlay(
            Group{
                if session.dbUser.blockedIds.contains(otherId){
                    Color.black.opacity(0.2)
                }
                   
            }
        )
        
    
        .background(
         
            Color.clear
                .overlay{
                    
                    if let user = chat.user, let progressDict = viewModel.completedUploadingSteps[user.id], let allStepsDict = viewModel.uploadAllSteps[user.id] {
                        ZStack(){
                            ForEach(progressDict.sorted(by: { $0.key < $1.key }), id: \.key) { id, steps in
                                if steps != -1{
                                    HStack{
                                        Rectangle()
                                        
                                            .frame(width: screenWidth * steps/allStepsDict[id]!)
                                            .foregroundColor(.blue.opacity(0.1))
                                        
                                        Spacer()
                                    }
                                    
                                    
                                    
                                }
                            }
                        }
                        
                 
                    }
                    
              
                   
                }
                
        )
        

    }
    
    
    @ViewBuilder
    var chatContent: some View{
        
        HStack{
            if ownAccount {
                checkMark
            }
            
            if chat.isReply{
                Text("Replied:")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .light))
            }
            
            if chat.text != ""{
                Text(chat.text)
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .light))
                    .lineLimit(1)
                    .padding(.trailing, ownAccount ? -5 : 0)
                
            } else if let url = chat.urls?.first, url.contains("Image") {
                Image(systemName: "camera.fill")
                    .foregroundColor(.gray.opacity(0.6))
            } else if let url = chat.urls?.first, url.contains("Video") {
                Image(systemName: "video.fill")
                    .foregroundColor(.gray.opacity(0.6))

            }else if chat.isPost{
                messageTypeIcon(text: "Post")
                
            }else if chat.isListing{
                
                messageTypeIcon(text: "Listing")
                
            }
        }
    }
    
    
    
    
    var checkMark: some View {
        
        
            HStack{
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.blue.opacity(chat.delivered ? 1: 0.0))
            }
           
            .overlay(
                
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.blue.opacity(chat.seen ? 1: 0.0))
                    .offset(x: 3)
                , alignment: .center
            )
        
    }
    
    @ViewBuilder
    func messageTypeIcon(text: String) -> some View{
        
        Text(text)
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.white)
            .padding(.vertical, 2)
            .padding(.horizontal, 10)
            .background(.gray.opacity(0.6))
            .cornerRadius(4)


        
    }
    
}


