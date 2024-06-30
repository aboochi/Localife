//
//  ChatBoxView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//

import SwiftUI
import Kingfisher

struct ChatBoxView: View {
    @Environment(\.dismiss)  var dismiss
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ChatViewModel
    @Binding var chatClosed: String?
    @State var scrollToEnd: Bool = false
    @State private var scrollToId: String?
    @FocusState private var focus: FocusableField?
    @State var currentImagePickerId: String = ""
    @State var showContextMenu: Bool = false
    @State var selectedMessage: Message?
    @State var selectedMessageGeometry: [String: GeometryProxy] = [:]
    @State  var swipeOffset: [String : CGFloat] = [ : ]
    @State  var originalOffset: [String : CGFloat] = [ : ]
    @State var closeChat: Bool = false
    @Binding var closeNewMessage: Bool
    @State var listing : Listing?
    @Binding var path : NavigationPath
    @StateObject  var homeIndex = HomeIndex.shared
    @State var showMoreOptions: Bool = false

    
    
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @StateObject  var keyboardManager = KeyboardManager()

    @State var scrollOffset: CGFloat = 0

    
    
    var body: some View {
        
            ZStack{
                VStack {
                    
                    ScrollViewReader() { proxy in
                        ScrollView(showsIndicators: false) {
                            
                            
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.messages.reversed().enumerated()), id: \.element.id) { index, message in
                                    
                                    
                                    
                                    VStack{
                                        
                                        
                                        let ownAccount = message.ownerId == session.dbUser.id
                                        displayDate(index: index, message: message)
                                        MessageCellView(message: message, otherUser: viewModel.otherUser, scrollToId: $scrollToId)
                                            .environmentObject(viewModel)
                                        
                                            .modifier(messageCellModifier(message: message, ownAccount: ownAccount, selectedMessage: $selectedMessage, showContextMenu: $showContextMenu, selectedMessageGeometry: $selectedMessageGeometry, swipeOffset: $swipeOffset, originalOffset: $originalOffset)
                                                      //.environmentObject(keyboardManager)
                                            )
                                        
                                        
                                        
                                        
                                    }
                                    
                                    .padding(.bottom, (message.reactions?.count ?? 0) > 0 ? 10 : 5)
                                    .padding(.top, message.isReply ? 5:0)
                                    
                                    .padding(.bottom, message.reactions != nil ? 10 : 0)
                                    .id(message.id)
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                                
                                .onChange(of: scrollToEnd, { oldValue, newValue in
                                    if newValue{
                                        proxy.scrollTo(viewModel.messages.first?.id, anchor: .bottom)
                                        withAnimation{
                                            scrollToEnd = false
                                        }
                                        
                                    }
                                })
                                
                                .onChange(of: scrollToId, { oldValue, newValue in
                                    if let messageId = newValue{
                                        proxy.scrollTo(messageId, anchor: .bottom)
                                        scrollToId = nil
                                        
                                    }
                                })
                                
                                
                                .onAppear{
                                    
                                    proxy.scrollTo(viewModel.messages.first?.id, anchor: .bottom)
                                }
                            }
                            .offset(y: scrollOffset )
                            
                            
                            
                            
                            
                        }
                        
                        
                        .refreshable {
                            
                            viewModel.fetchCount += 5
                            viewModel.fetchMessages()
                            
                        }
                        
                        
                        
                    }
                    
                    .onChange(of: keyboardManager.keyboardHeight, { oldValue, newValue in
                        
                        if let lastMessageId = viewModel.messages.first?.id,  let geo = selectedMessageGeometry[lastMessageId] {
                            
                            //                        print("last message maxY: \(geo.frame(in: .global).maxY)")
                            //                        print("keyboard height;  >>>>>>> \(newValue)")
                            //                        print("screenHeight - newValue;  >>>>>>> \(screenHeight - newValue)")
                            
                            let maxY = geo.frame(in: .global).maxY
                            if maxY  > screenHeight - newValue &&  newValue > 0{
                                
                                if screenHeight - maxY < 0{
                                    //withAnimation {
                                    scrollOffset =  -newValue - 45
                                    //}
                                }else{
                                    // withAnimation {
                                    scrollOffset = -((maxY - screenHeight + newValue)) - 45
                                    // }
                                }
                                
                            }else if newValue == 0{
                                //withAnimation {
                                scrollOffset = -keyboardManager.keyboardHeight
                                // }
                                
                            }
                        }
                    }
                              
                              
                    )
                    
                    .onChange(of: viewModel.messages) { oldValue, newValue in
                        
                        if let oldLastMessageId = oldValue.last?.id, let newLastMessageNewId = newValue.last?.id {
                            if oldLastMessageId != newLastMessageNewId {
                                // scrollToEnd = true
                            }
                        }
                        
                    }
                    
                    
                    .onChange(of: viewModel.showImagePicker) { oldValue, newValue in
                        
                        if oldValue == true && newValue == false {
                            viewModel.imagePickerViewModels[currentImagePickerId] = nil
                        }
                    }
                    
                    .onChange(of: homeIndex.listing) { _, newValue in
                        listing = homeIndex.listing
                    }
                    
                    Spacer()
                    
                    
                    
                    
                    messageTextField { sendMessage()}
                    
                    
                        .overlay {
                            if session.dbUser.blockedIds.contains(viewModel.otherUser.id){
                                
                                Text("Unblock to message")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal)
                                    .frame(height: 45)
                                    .frame(maxWidth: .infinity)
                                    .background(.black)
                                    .clipShape(Capsule())
                                    .padding(.horizontal)
                                
                                
                            }
                        }
                    
                    
                    
                }
                
                .onTapGesture {
                    focus = nil
                }
                .blur(radius: showContextMenu ? 30:0)
                
            }
            
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: leadingBar, trailing: trailingBar)

        
        
        .onChange(of: closeChat, { oldValue, newValue in
            if newValue{
                
                closeNewMessage = true
                chatClosed = viewModel.otherUser.id
                
                homeIndex.closedChatId = viewModel.otherUser.id
                dismiss()
            }
        })
        
        
        
        .onChange(of: session.dbUser.blockedIds, { oldValue, newValue in
            if newValue.contains(viewModel.otherUser.id){
                dismiss()
            }
        })
        
        
     
    
       
        
        .fullScreenCover(isPresented: $viewModel.showImagePicker, content: {
            
            MessageImagePickerView(pickerId: currentImagePickerId)
                .environmentObject(viewModel.imagePickerViewModels[currentImagePickerId] ?? ImagePickerViewModel())
        })
        
        .navigationBarHidden(showContextMenu)
        
        .overlay{
            if showContextMenu{
                contextMenuOverLay
                    .ignoresSafeArea()
            }
            
        }
        
        
        
    }
    
    
}





extension ChatBoxView {
    
    
    func sendMessage() {
        
        if viewModel.editedMessage != nil{
            
            Task{
               
                try await viewModel.editMesssage()
            }
        }else{
        
            Task{
                
                try await viewModel.sendMesssage()
                viewModel.messageContent = ""
                //focus = nil
                scrollToEnd = true
            }
        }
    }
    
    @ViewBuilder
    func displayDate(index: Int, message: Message)-> some View{
        
        if index == 0 || viewModel.messages.reversed()[index - 1].timestampDate != message.timestampDate {
            Text(message.timestampDate ?? "")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .thin))
                .padding(.vertical, 5)
        }
    }
    
    
    
    
    @ViewBuilder
    func messageTextField( action: @escaping () -> Void) -> some View{
        
        VStack{
            
            if let editedMessage = viewModel.editedMessage{
                
                VStack{
                    Rectangle()
                        .frame(width: screenWidth, height: 0.5)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    HStack{
                        
                        Text("Editing your message...")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.editedMessage = nil
                            viewModel.messageContent = ""
                            focus = nil
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .font(.system(size: 19, weight: .light))
                                .padding(.trailing, 15)
                        })
                    }
                    .padding(.horizontal, 10)
                    
                }
                .onAppear{
                    focus = .message
                    viewModel.messageContent = editedMessage.text
                }
            }
            
            
            
            
            if let repliedMessage = viewModel.repliedMessage{
           
                VStack(alignment: .leading){
                    Rectangle()
                        .frame(width: screenWidth, height: 0.5)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    HStack(alignment: .center){
                        VStack(alignment: .leading){
                            HStack{
                                Text("Replying to:")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.gray)
                                
                                
                                Text("\(repliedMessage.ownerId == viewModel.currentUser.id ? viewModel.currentUser.username ?? repliedMessage.ownerUsername : viewModel.otherUser.username ?? repliedMessage.ownerUsername)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            HStack{
                            
                                if repliedMessage.text != ""{
                                    Text(repliedMessage.text)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.black.opacity(0.8))
                                        .padding(.horizontal, 10)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(maxWidth: screenWidth * 0.8)
                                }
                                
                                Spacer()
                            }
                             
                        }
                        
                        Spacer()
                      
                        HStack(alignment: .center){
                           
                            if let thumbnailUrl = repliedMessage.thumbnailUrls?.first {
                                KFImage(URL(string: thumbnailUrl))
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding(.horizontal, 10)
                                    .padding(.top, 6)
                                    .padding(.bottom, 2)

                            }
                                
                            
                            Button(action: {
                                viewModel.repliedMessage = nil
                                focus = nil
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                    .font(.system(size: 19, weight: .light))
                                    .padding(.trailing, 15)
                            })
                        }
                    }

                }
                .onAppear{
                    focus = .message
                }
               
            }
            
            HStack(spacing: 15) {
                
                TextField("Message...", text: $viewModel.messageContent)
                    .padding(.horizontal)
                    .frame(height: 45)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Capsule())
                    .focused($focus, equals: .message)
                    .overlay{
                        if viewModel.messageContent.isEmpty{
                            imagePickerOverlay
                            
                        }
                    }
                
                if !viewModel.messageContent.isEmpty {
                    Button(action: action) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
        }
        .background(.gray.opacity(viewModel.repliedMessage == nil ? 0.0:0.1))
    }
    
    
    var imagePickerOverlay: some View {
        
        HStack{
            Spacer()
            Button {
                
                let id = UUID().uuidString
                currentImagePickerId = id
                viewModel.imagePickerViewModels[id] = ImagePickerViewModel()
                
                viewModel.showImagePicker = true
            } label: {
                Image(systemName: "photo")
                    .font(.system(size: 27, weight: .thin))
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
            }
        }
    }
    
    
    

            
              
                                        
         
            
       
        
        
        @ViewBuilder
        var leadingBar: some View{
            
            HStack(alignment: .center){
                
                
                Button(action: {
                    
                    if homeIndex.chatTargetUser != nil{
                        homeIndex.chatTargetUser = nil
                        homeIndex.currentIndex = 0
                        homeIndex.listing = nil
                        homeIndex.messageFrom = .profile
                    }
                    
                    closeChat = true
                    if path.count > 0{
                        path.removeLast()
                    }
                    
                }, label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                })
                
                
                Button {
                    let value = NavigationValuegeneral(type: .profile, user: viewModel.otherUser)
                    path.append(value)
                } label: {
                    AvatarView(photoUrl: viewModel.otherUser.photoUrl, username: viewModel.otherUser.username, size: 30)
                    Text(viewModel.otherUser.username ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }

          
                
            }
            
        }
  
        
        @ViewBuilder
        var trailingBar: some View{
            
            
            Button {
                showMoreOptions = true
            } label: {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.black)
            }

            
           
                .sheet(isPresented: $showMoreOptions) {
                    
                    RestrictionOptionsView(viewModel: ProfileViewModel(user: viewModel.otherUser, currentUser: viewModel.currentUser), showOptions: $showMoreOptions, contentCategory: .message, contentId: nil, listing: nil, postCaption: nil)
                        .environmentObject(session)
                        //.environmentObject(ProfileViewModel(user: user, currentUser: session.dbUser))
                        .presentationDetents([ .height(180) ])
                }
        }
            
    
    
    
    var contextMenuOverLay: some View {
        
        ZStack{
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.black.opacity(0.2))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    
                    showContextMenu = false
                }
            if let message = selectedMessage , let geometry = selectedMessageGeometry[message.id]{
                MessageContextMenu(showContextMenu: $showContextMenu, selectedMessage: message, selectedMessageGeometry: geometry)
            }
        }
    }

}


struct messageCellModifier: ViewModifier{
    @EnvironmentObject var viewModel: ChatViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    let message: Message
    let ownAccount: Bool
    @Binding var selectedMessage: Message?
    @Binding var showContextMenu: Bool
    @Binding var selectedMessageGeometry: [String: GeometryProxy]
    
    @Binding  var swipeOffset: [String : CGFloat]
    @Binding  var originalOffset: [String : CGFloat]
    @State var navigationIsActive: Bool = false
    @State var post: Post?
    @State var listing: Listing?
    let  screenHeight =  UIScreen.main.bounds.height
    

   
    func body(content: Content) -> some View {
        
        content
        
            .overlay (
                HStack {
                    
                    if let reactions = message.reactions, reactions.count > 0{
                        let keys = Array(reactions.keys)
                        let values = Array(reactions.values)
                        if values.count == 2{
                            HStack{
                                Text(values[0])
                                Text(values[1])
                                  
                            }
                            .offset(x: 0, y: 15)
                            .padding(.horizontal, ownAccount ? 20 : 50)

                        }else{
                            Text(values[0])
                                .offset(x: 0, y: 15)
                                .padding(.horizontal, ownAccount ? 20 : 50)


                        }
                    }
                }
                , alignment: ownAccount ? .bottomTrailing : .bottomLeading
            )
        
        
            .background(
                GeometryReader { viewGeometry in
                    Color.clear
                        .onAppear {
                            
                            selectedMessageGeometry[message.id] = viewGeometry
                        }
                        
                }
            )
        
            .navigationDestination(isPresented: $navigationIsActive) {
                
                
                if let post = post, let user = post.user{
                    
                    
                    FeedSlideView(viewModel: FeedCellViewModel(post: post, currentUser: session.dbUser), appearedPostIndecis: .constant([0]), playedPostIndex: .constant(0), postIndex: 0, zoomedPost: .constant("") , isZooming: .constant(false),  sentUrl:  .constant("") , path: .constant(NavigationPath()), isPrimary: false , isCommentExpanded: .constant([post.id: false]))
                                              .environmentObject(session)
                }else if let listing = listing, let user = listing.user{
                    
                    ListingCoverCell(listing: listing, path: .constant(NavigationPath()) , appearedPostIndecis: .constant([0]), playedPostIndex: .constant(0), currentItemIndex: 0)
                }
                   
                }
        
            .onTapGesture {
                
                if let urls = message.urls, urls.count > 0, let aspectRatio = message.aspectRatio{
                    viewModel.showAlbum = true
                    viewModel.albumMessage = message
                    print("show album: >>>>>>>")
                   
                }else if message.isPost || message.isListing{
                    navigationIsActive = true
                }
            }
            .onLongPressGesture {
                
                if !session.dbUser.blockedIds.contains(viewModel.otherUser.id){
                    showContextMenu = true
                    selectedMessage = message
                    HapticManager.shared.generateFeedback(of: .impact(style: .heavy), intensity: .strong)

                }
            }
            .fullScreenCover(isPresented: $viewModel.showAlbum, content: {
                if let message = viewModel.albumMessage{
                    MessageAlbum(message: message)
                }
            })
        
        
            .offset(x: swipeOffset[message.id] ?? 0)
            
            .gesture(
                DragGesture()
                    .onChanged { value in
                        
                        if  value.translation.width > 0 {
                            swipeOffset[message.id] = originalOffset[message.id]! + value.translation.width
                        }
                    }
                    .onEnded { value in
                       
                        let threshold: CGFloat = 100
                        if let swipeOffset = swipeOffset[message.id], let originalOffset = originalOffset[message.id], swipeOffset - originalOffset > threshold {
                          
                            if !session.dbUser.blockedIds.contains(viewModel.otherUser.id){
                                viewModel.repliedMessage = message
                                HapticManager.shared.generateFeedback(of: .impact(style: .heavy), intensity: .medium)

                            }
                         
                         
                        }
                        
                        
                        withAnimation {
                            
                            swipeOffset[message.id] = 0
                        }
                        
                        
                        
                    }
            )
            
            
            .onAppear {
                swipeOffset[message.id] = 0
                originalOffset[message.id] = swipeOffset[message.id]
                
                Task{
                    if message.isPost{
                        post = try await  viewModel.fetchPost(message: message)
                    }else if message.isListing{
                        listing = try await viewModel.fetchListing(message: message)
                    }
                    
                }
            }
        
            
        
            .onTapGesture {
               
            }
        
            .fullScreenCover(isPresented: $viewModel.showAlbum, content: {
                if let message = viewModel.albumMessage{
                    MessageAlbum(message: message)
                }
            })
            
        
        
        
    }
    
    
}


import Combine
import UIKit

class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { notification in
                    notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                }
                .map { rect in
                    rect.height
                },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in
                    CGFloat(0)
                }
        )
        .receive(on: RunLoop.main)
        .assign(to: \.keyboardHeight, on: self)
    }
}


