import SwiftUI

// Enum definition
enum RestrictionOrderEnum{
    case hide
    case block
    case mute
    case none

}

enum RestrictionActionDoneEnum{
    case report
    case block
    case delete
    case mute
    case hide
    case unblock
    case unmute
    case unHide
    case none
}




struct RestrictionOptionsView: View {
    
    @StateObject var viewModel: ProfileViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @State private var showMuteAlert: Bool = false
    @State private var showDeleteAlert: Bool = false

    @Binding  var showOptions: Bool
    @State var showBlockSheet: Bool = false
    @State var showReportSheet: Bool = false
    let contentCategory : ContentCategoryEnum
    let contentId: String? 
    let listing: Listing?
    let postCaption: String?
    @State var caption: String = ""
    @State var showEditListing = false
    @State var showEditPost = false
    @State var actionDone: RestrictionActionDoneEnum = .none
   


    
    var body: some View {
        
            VStack {
                
                if viewModel.user.id != viewModel.currentUser.id{
                    
                    otherUserOption
                        .padding()
                }else{
                    myOwnOption
                        .padding()
                }
            
        }
        .padding()
        .onAppear{
            caption = postCaption ?? ""
        }
        
        
        .sheet(isPresented: $showBlockSheet, content: {
            ProfileBlockView( showOptions: $showOptions)
                .environmentObject(session)
                .environmentObject(viewModel)
                .presentationDetents([.height(400)])
        })
        
        .sheet(isPresented: $showReportSheet, content: {
            
            ProfileReportView(showOptions: $showOptions, contentId: contentId, contentCategory: contentCategory)
                .environmentObject(session)
                .environmentObject(viewModel)
        })
        
        .alert(isPresented: $showMuteAlert) {
                   Alert(
                       title: Text("User Muted"),
                       message: Text("What they share will not appear on your feeds anymore until you unmute them."),
                       dismissButton: .default(Text("Dismiss"), action: {
                           showOptions = false
                       })
                   )
               }
        
        .alert(isPresented: $showDeleteAlert) {
             Alert(
                title: Text(contentCategory == .listing ? "Delete Listing" :   "Delete Post"),
                 message: Text("Are you sure you want to delete this post? This action cannot be undone."),
                 primaryButton: .destructive(Text("Delete"), action: {
                     
                     Task{
                         try await viewModel.deleteContent(contentId: contentId, contentCategory: contentCategory)
                         showOptions = false
                         actionDone = .delete
                     }
                 }),
                 secondaryButton: .cancel(Text("Cancel"), action: {
                     showOptions = false
                 })
             )
         }
        
        
        
        
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
    
    
    
    
    @ViewBuilder
    var otherUserOption: some View{
        
        VStack{
            
            if contentCategory != .user, contentCategory != .message,  let contentId = contentId{
                Button {
                    Task{
                        if viewModel.currentUser.hiddenPostIds.contains(contentId){
                            try await viewModel.unHideContent(contentId: contentId)
                            session.userViewModel.dbUser?.hiddenPostIds.removeAll(where: {$0 == contentId})
                            actionDone = .unHide
                           
                            
                        }else{
                            try await viewModel.hideContent(contentId: contentId)
                            session.userViewModel.dbUser?.hiddenPostIds.append(contentId)
                            actionDone = .hide
                            
                        }
                    }
                    
                } label: {
                    option(text: viewModel.currentUser.hiddenPostIds.contains(contentId) ? "See content": "Hide content")
                }
            }
            
            
            
            if contentCategory != .message{
                Button {
                    Task{
                        
                        if viewModel.isMuted{
                            try await viewModel.unMuteUser()
                            session.userViewModel.dbUser?.mutedIds.removeAll(where: {$0 == viewModel.user.id})
                            showMuteAlert = true
                            actionDone = .unmute
                        }else{
                            try await viewModel.muteUser()
                            session.userViewModel.dbUser?.mutedIds.append(viewModel.user.id)
                            showMuteAlert = true
                            actionDone = .mute
                        }
                    }
                    
                } label: {
                    option(text: viewModel.isMuted ? "Unmute": "Mute")
                }
            }
            
            Button {
                
                showReportSheet = true
                
            } label: {
                option(text: "Report", color: .red)

            }
            
            Button {
                if !session.dbUser.blockedIds.contains(viewModel.user.id){
                    showBlockSheet = true
                }else{
                    Task{
                        try await viewModel.unBlockUser()
                        session.dbUser.blockedIds.removeAll(where: {$0 == viewModel.user.id})
                        viewModel.isBlocked = false
                        actionDone = .unblock
                        showOptions = false

                    }
                }
                
            } label: {
                option(text: session.dbUser.blockedIds.contains(viewModel.user.id) ? "Unblock" :  "Block" , color: .red)

            }
            
        }
    }
    
    
    @ViewBuilder
    var myOwnOption: some View{
        
        VStack{
            
            Button {
                if contentCategory == .listing{
                    showEditListing =  true
                }else if contentCategory == .post{
                    showEditPost = true
                }
                
            } label: {
                option(text: "Edit", color: .black)
            }
            
            Button {
                if contentCategory == .listing || contentCategory == .post {
                    showDeleteAlert = true
                    
                }
                
            } label: {
                option(text: "Delete", color: .red)
            }
        }
        .fullScreenCover(isPresented: $showEditListing, content: {
            if let listing = listing{
                CreateListingView(showCreateListing: $showEditListing , formType: .edit, listing: listing)
                    .environmentObject(CreateListingViewModel(user: session.dbUser))
            }
        })
        
        .fullScreenCover(isPresented: $showEditPost, content: {
            if let postId = contentId{
               EditPostCaptionView(viewModel: viewModel, showOptions: $showOptions, postId: postId, caption: $caption)
            }
        })

    }
        
}


