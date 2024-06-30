//
//  SwiftUIView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//

import SwiftUI
import Kingfisher

enum MessageColorCell: String {
    case currentUser = "#82c1dc"
    case otherUser = "#9993af"
}

struct MessageCellView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    let message: Message
    let otherUser: DBUser
    @Binding  var scrollToId: String?
    @EnvironmentObject var viewModel: ChatViewModel
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var ownAccount: Bool {
        return message.ownerId == session.dbUser.id
    }
    @State var post: Post?
    @State var listing: Listing?
    @State var selectedListing: Listing?
    @State var showListingSheet: Bool = false
    
    var body: some View {
        
        VStack{
            
            if message.isReply{
                
                HStack{
                    
                    if ownAccount{
                        Spacer()
                    }
                    Text("Replied to \(message.replyMessageOwnerId == otherUser.id ? otherUser.username ?? "": session.dbUser.username ?? "")")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.black)
                        .padding(.leading, !ownAccount  ? 37: 0)
                        .padding(.trailing, ownAccount  ? 7: 0)
                    if !ownAccount{
                        Spacer()
                    }
                }
             
            }
            HStack(alignment: .bottom, spacing: 5) {
                
                if !ownAccount {
                    AvatarView(photoUrl: otherUser.photoUrl, username: otherUser.username, size: 25)
                }
                
                if ownAccount {
                    Spacer(minLength: 5)
                }
                
                
                
                VStack(alignment: ownAccount ? .trailing : .leading , spacing: 0) {
                    
                    
                    
                    if message.isReply{
                        
                        
                        VStack(alignment: ownAccount ? .trailing : .leading){
                            
                            VStack(alignment: .leading){
                                
                                
                                if let text = message.repliedText , text != ""{
                                    Text(text)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 10)
                                    
                                }
                                
                                if let url = message.repliedImageUrl{
                                    KFImage(URL(string: url))
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(10)
                                        .padding(5)
                                }
                                if message.isReplyToPost{
                                    postMessagePreview(message: message, ownAccount: ownAccount)
                                        .scaleEffect(0.8)
                                        .frame(width: screenWidth * 0.56, height: (screenWidth * 0.56 / ((message.sharedPostAspectRatio) ?? 1)) + screenWidth * 0.1 )
                                    
                                    
                                    
                                }else if message.isReplyToListing{
                                    
                                    sharedListingPreview
                                        .scaleEffect(0.8)
                                        .frame(width: screenWidth * 0.45 * 0.8 , height: screenWidth * 0.45 * 0.8)
                                        .background(.white)

                                    
                                    
                                }
                            }
                            
                
                            
                            
                        }
                        .background(Color(hex: ownAccount ? MessageColorCell.currentUser.rawValue : MessageColorCell.otherUser.rawValue))
                        .overlay(Color.white.opacity(0.35), alignment: .center)
                        .clipShape(ReplyBubbleView(ownAccount: self.ownAccount))
                        .blur(radius: message.isHidden ? 30:0)

                        
                        .overlay(
                            
                            ReplyBubbleView(ownAccount: self.ownAccount)
                                .stroke(.white, lineWidth: 0.5)
                        )
                        
                        .padding(.leading, !ownAccount && message.isReply ? 7: 0)
                        .padding(.trailing, ownAccount && message.isReply ? 7: 0)
                        
                        .frame(maxWidth: screenWidth * 0.7, alignment: ownAccount ? .trailing : .leading)

                        .padding(.bottom, 1.5)
                        
                        .onTapGesture {
                            scrollToId = message.replyToMessageId
                        }
                        
                        
                    }
                    
                    
                    VStack(alignment: ownAccount ? .trailing : .leading , spacing: 0) {
                        
                        if message.isForwarded{
                            
                            Text("Forwarded")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                            
                        }
                        
                        if message.isDeleted{
                            Text("Deleted Message")
                                .font(.system(size: 14, weight: .ultraLight))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                        }else{
                            if message.text != ""{
                                Text(message.text)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.top, 10)
                                
                            } else if let thumbnails = message.thumbnailUrls , thumbnails.count > 0{
                                VStack{
                                    
                                    ImagesDisplayMessageCell(images: thumbnails, width: screenWidth * 0.75)
                                        .padding(.bottom, 0)
                                    
                                    
                                    if let caption = message.caption, !caption.isEmpty{
                                        Text(caption)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.top, 1)
                                        
                                    }
                                    
                                }
                                
                            } else if let croppedImages = message.croppedImage {
                                
                                ImagesDisplayMessageCell(images: croppedImages, width: screenWidth * 0.75)
                                    .padding(.bottom, 0)
                                    .overlay (
                                        CircularProgressView(progress: viewModel.completedUploadingSteps[message.id]!/viewModel.uploadAllSteps[message.id]!, size: 100)
                                        ,alignment: .center
                                    )
                                
                            }else if message.isPost{
                                
                                sharedPost
                                    .frame(width: screenWidth * 0.7, height: screenWidth * 0.7 / (post?.aspectRatio ?? (message.sharedPostAspectRatio ?? 1)))

                                
                            }else if message.isListing{
                                
                                sharedListing
                                    .frame(width: screenWidth * 0.45  , height: screenWidth * 0.55 )
                                    .padding(.horizontal, 5)
                                    .padding(.top, 5)
                                    .background(Color(hex: "#ebebeb"))

                            }
                        }
                        HStack(alignment: .center){
                            
                            
                            if ownAccount && !message.delivered , let croppedImages = message.croppedImage{
                                
                                Text("Sending...")
                                    .font(.system(size: 11, weight: .light))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 10)
                                  
                                    .padding(.vertical, 5)
                                
                            }
                            
                            if message.isEdited{
                                Text("Edited")
                                    .font(.system(size: 11, weight: .light))
                                    .foregroundColor(.white)
                                   
                                   
                             
                            }
                            
                            Text(message.timestampTextReal ?? "")
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(.white)
                                .padding(.trailing, ownAccount ? 0:5)
                             
                                .padding(.vertical, 5)
                            
                            if ownAccount{
                                HStack{
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .italic()
                                        .foregroundColor(.white.opacity(message.delivered ? 1: 0.2))
                                }
                                .padding(.vertical, 5)
                                .padding(.trailing, 10)
                                .overlay(
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .italic()
                                        .foregroundColor(.white.opacity(message.seen ? 1: 0.2))
                                        .padding(.trailing, 2)
                                    , alignment: .center
                                )
                            }
                            
                            
                            
                            
                        }
                        .frame(alignment: .trailing)
                        .padding(.leading, 10)
                    }
                    .background(Color(hex: ownAccount ? MessageColorCell.currentUser.rawValue : MessageColorCell.otherUser.rawValue))
                    .clipShape(MessageBubbleView(ownAccount: self.ownAccount))
                    .blur(radius: message.isHidden ? 30:0)

                    
                    .overlay(
                        
                        MessageBubbleView(ownAccount: self.ownAccount)
                            .stroke(.white, lineWidth: 0.5)
                    )
                    
                    
                    
                    
                    .padding(.leading, !ownAccount && message.isReply ? 7: 0)
                    .padding(.trailing, ownAccount && message.isReply ? 7: 0)
                    
                    .overlay(
                        
                        Group{
                            if message.isAboutListing{
                                sharedListingPreview
                                   
                                    .scaleEffect(0.1)
                                    .frame(width: screenWidth * 0.45 * 0.1, height: screenWidth * 0.45 * 0.1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(.white, lineWidth: 1)
                                    )
                                    .offset(x: -screenWidth * 0.45 * 0.1 - 5, y: 0 )
                                    
                                    .onTapGesture {
                                        if let listing = listing{
                                            selectedListing = listing
                                            showListingSheet = true
                                        }
                                    }
                            }
                        }
                        ,alignment: .topLeading
                    )
                    
                    .sheet(item: $selectedListing, onDismiss: {
                               selectedListing = nil
                          }) { listing in
                              
                              
                                  ListingCoverCell(listing: listing, path: .constant(NavigationPath()) , appearedPostIndecis: .constant([0]), playedPostIndex: .constant(0), currentItemIndex: 0)
                             
                              
                          }
                    
                    
                    
                    .frame(maxWidth: screenWidth * 0.7, alignment: ownAccount ? .trailing : .leading)
                    
                   
                    
                    
                    
                }
                
                .overlay(
                    
                    HStack{
                        if  message.isReply{
                            Rectangle()
                                .frame(maxWidth: 6, maxHeight: .infinity)
                                .foregroundColor(Color(hex: ownAccount ? MessageColorCell.currentUser.rawValue : MessageColorCell.otherUser.rawValue).opacity(0.7))
                                .overlay(
                                    Rectangle()
                                        .stroke(.white, lineWidth: 0.5)
                                )
                            
                            
                            
                        }
                    }
                    , alignment: ownAccount ? .trailing : .leading
                    
                )
                
                
                if !ownAccount {
                    Spacer(minLength: 0)
                }
                
                
            }
         
        }
        .padding(.horizontal, 10)
//        .padding(.bottom, (message.reactions?.count ?? 0) > 0 ? 10 : 5)
//        .padding(.top, message.isReply ? 5:0)
        
        
        .sheet(isPresented: $viewModel.showSharePostVew) {
            UsersToSendToView(sentUrl: .constant(""))
                .environmentObject(SharePostViewModel(currentUser: session.dbUser, shareCategory: .message,  forwardedMessage: message))
                .presentationDetents(
                                    [.medium, .large]
                                   
                                 )
        }
        
        
        
        
        
        
        .onAppear{
            Task{
                if !ownAccount{
                    try await viewModel.markSeen(message: message)
                }
            }
        }
        
    }
    
    
    
    
    @ViewBuilder
    var sharedListingPreview : some View{
        
        if let listing = listing {
            
            ListingCoverCellExplore(listing: listing)
                .offset(y : screenWidth * 0.05 )
                .frame(width: screenWidth * 0.45, height: screenWidth * 0.45)
                .clipped()

               
            
        }else{
            
            Rectangle()
                .foregroundColor(.gray)
                .frame(width: screenWidth * 0.45, height: screenWidth * 0.45)
               

                .onAppear{
                    Task{
                        try await listing = viewModel.fetchListing(message: message)
                    }
                }
        }
    }
    
  
    
    @ViewBuilder
    var sharedListing: some View{
        
        if let listing = listing, let user = listing.user {
            
            ListingCoverCellExplore(listing: listing)
                .padding()
            
        }else{
            
            Rectangle()
                .foregroundColor(.gray)
                .frame(width: screenWidth * 0.45, height: screenWidth * 0.55)
                .padding()

                .onAppear{
                    Task{
                        try await listing = viewModel.fetchListing(message: message)
                    }
                }
        }
    }
    
    
    
    
    @ViewBuilder
    var sharedPost : some View{
        
        
        
        if message.isPost{
            
            if let post = post, let user = post.user{
                
               
                    
                        
                VStack(alignment: .leading){
                            if let thumbnail = post.thumbnailUrls.first{
                                if thumbnail.contains("Image"){
                                    HStack{
                                        AvatarView(photoUrl: user.photoUrl, username: user.username, size: 20)
                                        if let username = user.username{
                                            Text(username)
                                                .foregroundColor(.black)
                                                .font(.system(size: 12, weight: .semibold))
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                    }
                                    .padding([.horizontal, .top], 10)
                                   // .background(.gray)
                                    
                                }
                                KFImage(URL(string: thumbnail))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth * 0.7, height: screenWidth * 0.7 / post.aspectRatio)
                                    .clipped()
                                

                                
                                VStack{
                                    if !post.caption.isEmpty, let username = user.username{
                                        
                                        Group{
                                            Text(username)
                                                .foregroundColor(.black)
                                                .font(.system(size: 12, weight: .semibold))
                                            +
                                            Text(" ")
                                            +
                                            Text(post.caption)
                                                .foregroundColor(.black)
                                                .font(.system(size: 12, weight: .regular))
                                            
                                        }
                                        .lineLimit(1)
                                        .padding(.bottom, 10)
                                        .padding(.horizontal, 5)
                                        
                                        
                                    }
                                }
                                .frame(height: 25)
                                
                            }
                        }
                        .frame(maxWidth: screenWidth * 0.7, alignment: ownAccount ? .trailing : .leading)
                        .background(Color(hex: "#ebebeb"))
                

                
                
                
            }else{
                postMessagePreview(message: message, ownAccount: ownAccount)

                    .onAppear{
                        Task{
                           post = try await  viewModel.fetchPost(message: message)
                        }
                    }
            }
           
            
        }else if message.isStory{
            
        }
    }
    
}


struct postMessagePreview: View{
    let message : Message
    let ownAccount: Bool
    let screenWidth = UIScreen.main.bounds.width
    var body: some View{
        
        VStack{
            if let thumbnail = message.sharedPostThumbnail{
                if thumbnail.contains("Image"){
                    HStack{
                        AvatarView(photoUrl: message.sharedPostOwnerPhotoUrl, username: message.sharedPostOwnerUsername, size: 20)
                        if let username = message.sharedPostOwnerUsername{
                            Text(username)
                                .foregroundColor(.black)
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                            
                        }
                        Spacer()
                    }
                    .padding([.horizontal, .top], 10)
                   // .background(.gray)
                    
                }
                KFImage(URL(string: thumbnail))
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth * 0.7, height: screenWidth * 0.7 / (message.sharedPostAspectRatio ?? 1))
                
                VStack{
                    
                }
                .frame(height: 25)
                
                
            }
        }
        .frame(maxWidth: screenWidth * 0.7, alignment: ownAccount ? .trailing : .leading)
        .background(Color(hex: "#ebebeb"))
        .padding(.top, 10)
    }
}

