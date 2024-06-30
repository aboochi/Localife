//
//  MessageView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/14/24.
//

import SwiftUI
import Foundation
import SwipeActions


struct MessageView: View {
    @State var searchText: String = ""
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: MessageViewModel
    @State var state: SwipeState = .untouched
    @State var showNewChat: Bool = false
    @State var selectedUser: DBUser?
    @StateObject  var homeIndex = HomeIndex.shared
    @State  var listing: Listing? = nil
    @State var path = NavigationPath()


    
    var body: some View {
        
        if let otherUser = homeIndex.chatTargetUser{
            
            if homeIndex.messageFrom == .listing{
            
            if let listing = listing{
                NavigationStack{
                    
                    
                    
                    if  viewModel.chatBoxViewModels[otherUser.id]  != nil{
                       
                        ChatBoxView(chatClosed: $viewModel.chatClosed, closeNewMessage: .constant(false), path: $path)
                            .environmentObject(viewModel.chatBoxViewModels[otherUser.id]!)
                            .environmentObject(session)
                    }
                }
                    .onAppear{
                        
                        print("listing has been called inside messageivew ______________")
                    viewModel.chatBoxViewModels[otherUser.id]?.listing = homeIndex.listing
                }
                
               
            }else{
                
                Color.clear
                
                    .onAppear{
                        
                        if viewModel.chatBoxViewModels[otherUser.id] == nil{
                            
                            viewModel.chatBoxViewModels[otherUser.id] = ChatViewModel(currentUser: session.dbUser, otherUser: otherUser)
                            listing = homeIndex.listing
                            viewModel.updatePreviewUI.toggle()
                        }else{
                            
                            viewModel.chatBoxViewModels[otherUser.id]?.listing = homeIndex.listing
                            listing = homeIndex.listing
                            
                            
                        }
                    }
            }
            }else{
                
                NavigationStack{
                    
                    if let chatViewModel = viewModel.chatBoxViewModels[otherUser.id] {
                        ChatBoxView(chatClosed: $viewModel.chatClosed, closeNewMessage: .constant(false), path: $path)
                            .environmentObject(chatViewModel)
                            .environmentObject(session)
                    }
                   
                }
                .onAppear{
                    print("profile has been called inside messageivew ______________")
                    if viewModel.chatBoxViewModels[otherUser.id] == nil{
                        
                        DispatchQueue.main.async {
                            viewModel.chatBoxViewModels[otherUser.id] = ChatViewModel(currentUser: session.dbUser, otherUser: otherUser)
                            viewModel.updatePreviewUI.toggle()
                        }
                       
                    }
                }
            }
            
        }else{
            
            NavigationStack(path: $path){
                VStack{
                    
                    ScrollViewReader { reader in
                        ScrollView(showsIndicators: false){
                            LazyVStack{
                                ForEach($viewModel.chats, id: \.id){ $chat in
                                    
                                    let otherUid = chat.recipientId == session.dbUser.id ? chat.ownerId : chat.recipientId
                                    
                                    Button {
                                        if let chatViewModel = viewModel.chatBoxViewModels[chat.recipientId == session.dbUser.id ? chat.ownerId : chat.recipientId] {
                                            
                                            let value = NavigationValuegeneral(type: .chatbox, chatViewModel: chatViewModel,  userId: otherUid)
                                            path.append(value)
                                            
                                        }
                                    
                                    } label: {
                                        LongTapPreview(updatePreviewUI: $viewModel.updatePreviewUI){
                                            
                                            
                                            LastMessageCell(chat: chat, currentUser: session.dbUser)
                                                .id(chat.id)
                                        }
                                        
                                        
                                        
                                    preview: {
                                        
                                        
                                        ChatBoxView( chatClosed: $viewModel.chatClosed , closeNewMessage: .constant(false), path: $path)
                                            .environmentObject(viewModel.chatBoxViewModels[otherUid] ?? ChatViewModel(currentUser: session.dbUser, otherUser: session.dbUser))
                                            .environmentObject(session)
                                        
                                        
                                        
                                    } actions: {
                                        
                                        return UIMenu(title: "actions", children: [
//                                            UIAction(title: " Mute", image: UIImage(systemName: "speaker.slash")) { _ in
//                                                
//                                            },
//                                            UIAction(title: " Archive", image: UIImage(systemName: "archivebox")) { _ in
//                                                
//                                            },
                                            UIAction(title: " Delete", image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)) { _ in
                                                Task{
                                                    try await viewModel.deleteChats(otherId: otherUid)
                                                }
                                            },
                                            
                                        ])
                                        
                                    }
                                        
                                    .onAppear{
                                        
                                        
                                        
                                        Task{
                                            if let user = chat.user{
                                                
                                            }else{
                                               // try await chat.setUserOwner(uid: otherUid)
                                                try await viewModel.setUserOwner(message: &chat, uid: otherUid)
                                            }
                                            
                                            if viewModel.chatBoxViewModels[otherUid] == nil , let otherUser = chat.user{
                                               
                                                viewModel.addChatViewModel(currentUser: session.dbUser, otherUser: otherUser)
                                                   
                                                    viewModel.updatePreviewUI.toggle()
                                                
                                            }
                                        }
                                    }
                                        
                                        
                                    .addSwipeAction(edge: .trailing,  state : $state){
                                        SwipeActionButtons(chat: chat, otherId: otherUid)
                                        
                                    }
                                        
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
//                    Button(action: {
//                        Task{
//                        }
//                        
//                    }, label: {
//                        Text("See more")
//                            .padding(10)
//                            .foregroundColor(.black)
//                            .frame(maxWidth: .infinity)
//                            .padding(10)
//                    })
                }
                .id(viewModel.updateThisUI)
                
                
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                //.searchable(text: $searchText)
                .navigationBarItems(leading:
                                        
                                        Button(action: {
                    homeIndex.currentIndex = 0
                }, label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                })
                                    
                                    
                                    , trailing:
                                        
                                        
                                        NavigationLink(destination: {
                    NewMessageView(chatClosed: $viewModel.chatClosed, path: $path )
                        .environmentObject(viewModel)
                        .environmentObject(session)
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
                                    
                                    
                                    
                )
                .navigationTitle("")
                .modifier(Navigationmodifier(path: $path))

            
            }
            

      
            
            .onChange(of: homeIndex.closedChatId, { oldValue, newValue in
                
                print("new value >>> \(newValue)")
                if oldValue == nil && newValue != nil{
                    viewModel.subscribeToChildSteps(id: newValue!)
                    viewModel.subscribeToChilduploadAllSteps(id: newValue!)
                    showNewChat = false
                    homeIndex.closedChatId = nil
                    viewModel.reloadView()
                    
                    
                }
                
            })
            
            .onChange(of: viewModel.updateThisUI, { oldValue, newValue in
                
                viewModel.reloadView()
                
            })
            
            
            .onAppear{
                
                print("Ipad screen: \(UIScreen.main.bounds)")
            }
            
        }
    }
    
    
    @ViewBuilder
    func SwipeActionButtons(chat: Message, otherId: String) -> some View{
        
        Button {
            
            print("remove")
            Task{
                try await viewModel.deleteChats(otherId: otherId)
                state = .swiped(UUID(uuidString: chat.id)!)
                
            }
            
            
            
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.white)
        }
        .frame(width: 120, height: 60, alignment: .center)
        .contentShape(Rectangle())
        .background(Color.red)
        
//        Button {
//            print("Mute")
//            state = .swiped(UUID(uuidString: chat.id)!)
//            
//        } label: {
//            Image(systemName: "speaker.slash")
//                .foregroundColor(.white)
//        }
//        .frame(width: 60, height:  60, alignment: .center)
//        .background(Color.blue)
//        
//        Button {
//            
//            print("Edit")
//            state = .swiped(UUID(uuidString: chat.id)!)
//            
//        } label: {
//            Image(systemName: "archivebox")
//                .foregroundColor(.white)
//        }
//        .frame(width: 60, height:  60, alignment: .center)
//        .background(Color.gray)
    }
    
    
}




