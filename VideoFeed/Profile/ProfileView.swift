//
//  ProfileView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/21/24.
//

import SwiftUI



enum ProfileNavigationType{
    case setting
    case followers
    case following
    case neighbors
    case editProfile
    case postExplore
    case popularPost
    case listingExplore
    case popularListing
    case none
}

struct NavigationValue: Hashable {
    var name: ProfileNavigationType
    var contentId: String
    var index: Int
}



struct ProfileView: View {
    
    // @Environment(\.dismiss) var dismiss
    @EnvironmentObject var session : AuthenticationViewModel
    @StateObject var viewModel: ProfileViewModel
    @StateObject var listingViewModel: ListingViewModel
    @State var presentImagePicker = false
    @State var actionOrderFollowers: FollowActionOrder = .none
    @State var actionOrderFollowing: FollowActionOrder = .none
    @State var selectedId: String?
    @State  var showOptions: Bool = false
    @State var activeFollowerNav: Bool = false
    @State var activeFollowingNav: Bool = false
    
    @Binding var path: NavigationPath
    @StateObject  var homeIndex = HomeIndex.shared
    let spacing: CGFloat = 5
    @State  var selectedOption = "Posts"
    let options = ["Posts", "Listings"]
    
    @State var navigationType: ProfileNavigationType = .none
    @State var contentId: String = ""
    @State var navigationIndex: Int = 0
    @State var selectedListingId: String = ""
    let isPrimary: Bool
    @State var selectedImage: UIImage?

    
    
    
    
    let screenWidth = UIScreen.main.bounds.width
    var body: some View {
        
        
        VStack{
            
            ScrollViewReader{ proxy in
                ScrollView(showsIndicators: false){
                    
                    VStack{
                        VStack{
                            
                            avatarAndNeighbor
                                .id(0)
                            
                            HStack(alignment: .bottom){
                                
                                profileBio
                                Spacer()
                                badge
                            }
                            .padding(.horizontal)
                            
                            
                            if viewModel.isMyOwnAccount{
                                
                                
                           
                                    
                                    Button {
                                        
                                        
                                        let value = NavigationValuegeneral(type: .editProfile, profileViewModel:  viewModel)
                                        path.append(value)
                                       // path.append(NavigationValue(name: .editProfile, contentId: "", index: 0))
                                        
                                    } label: {
                                        
                                        stats(text: "Edit Profile", size: .infinity, color: .white)
                                            .padding(.vertical, 15)
                                    }
                                    .padding(.horizontal)
                                    
                                    
                                    
                                
                                
                            } else{
                                
                                HStack(spacing: 10){
                                    Button(action: {
                                        
                                        handleUserAction()
                                        
                                    }, label: {
                                        
                                        getButtonLabel()
                                    })
                                    
                                    
                                    Button {
                                        homeIndex.currentIndex = 1
                                        homeIndex.chatTargetUser = viewModel.user
                                        homeIndex.messageFrom = .profile
                                    } label: {
                                        stats(text: "Message", size: .infinity, color: .white)
                                    }
                                    
                                    
                                    
                                }
                                .padding(.horizontal)
                                
                            }
                            
                        }
                        
                        ProfileBodyView
                        
                        Spacer()
                    }
                    
                }
                .onChange(of: homeIndex.profileScrollTotop, { oldValue, newValue in
                    
                    if newValue{
                        withAnimation{
                            proxy.scrollTo(0, anchor: .top)
                        }
                        homeIndex.profileScrollTotop = false
                    }
                })
                
                
                
                
                .refreshable {
                    
                    
                    Task{
                        do{
                            viewModel.lastPostDocument = nil
                            viewModel.lastListingDocument = nil
                            viewModel.listings  = []
                            viewModel.mostPopularpost = nil
                            viewModel.mostRecentListing =  nil
                            viewModel.posts = []
                            viewModel.allPosts = []
                            listingViewModel.listingActiveOtherUser = []
                            listingViewModel.lastDocumentActiveOtherUser = nil
                            
                            try await listingViewModel.fetchOtherUserActiveListing(uid: viewModel.user.id)
                            try await viewModel.refreshUser()
                            try await viewModel.fetchPopularPost()
                            try await viewModel.fetchPost()
                            try await viewModel.fetchUserActiveListing()
                            try await viewModel.setFollowingStatus()
                            try await viewModel.setRequestStatus()
                            viewModel.checkBlockAndMute()
                        }
                    }
                    
                }
                
                
                    
                        .modifier(Navigationmodifier(path: $path))

                
                
            }
        }
        
        .sheet(isPresented: $showOptions, content: {
            RestrictionOptionsView(viewModel: viewModel, showOptions: $showOptions, contentCategory: .user, contentId: nil, listing: nil, postCaption: nil)
                .environmentObject(session)
            //.environmentObject(viewModel)
                .presentationBackground(.white.opacity(1))
                .presentationDetents([.height(250)])
        })
        
        .onAppear{
            
            
            Task{
                
                try await viewModel.fetchPopularPost()
                try await viewModel.fetchPost()
                try await viewModel.fetchUserActiveListing()
                
            }
        }
        
        
        .onAppear{
            
            if !listingViewModel.marketViewAppeared{
                
                Task{
                    listingViewModel.listingActiveOtherUser = []
                    listingViewModel.lastDocumentActiveOtherUser = nil
                    try await listingViewModel.fetchOtherUserActiveListing(uid: viewModel.user.id)
                    listingViewModel.marketViewAppeared = true
                    
                }
            }
        }
        
        
        .onChange(of: actionOrderFollowers, { oldValue, newValue in
            
            switch newValue{
            case .fetch:
                Task{
                    viewModel.lastDocumentFollowers = nil
                    viewModel.followerIds = []
                    try await viewModel.getFollowers()
                    actionOrderFollowers = .none
                }
            case .fetchMore:
                Task{
                    try await viewModel.getFollowers()
                    actionOrderFollowers = .none
                }
            case .follow:
                if let newId = selectedId, viewModel.user.id == session.dbUser.id{
                    viewModel.followingIds.append(newId)
                    
                }
                
                session.userViewModel.dbUser?.followingNumber += 1
                selectedId = nil
                actionOrderFollowers = .none
            case .unfollow:
                if let newId = selectedId, viewModel.user.id == session.dbUser.id{
                    viewModel.followingIds.removeAll{ $0 == newId}
                    
                }
                session.userViewModel.dbUser?.followingNumber -= 1
                selectedId = nil
                actionOrderFollowers = .none
            case .remove:
                if let newId = selectedId, viewModel.user.id == session.dbUser.id{
                    viewModel.followerIds.removeAll{ $0 == newId}
                    
                }
                session.userViewModel.dbUser?.followerNumber -= 1
                selectedId = nil
                actionOrderFollowers = .none
                
                
            case .none:
                actionOrderFollowers = .none
            }
            
            
        })
        
        .onChange(of: actionOrderFollowing, { oldValue, newValue in
            
            switch newValue{
            case .fetch:
                Task{
                    viewModel.lastDocumentFollowing = nil
                    viewModel.followingIds = []
                    try await viewModel.getFollowing()
                    actionOrderFollowing = .none
                }
            case .fetchMore:
                Task{
                    try await viewModel.getFollowing()
                    actionOrderFollowing = .none
                }
            case .follow:
                if let newId = selectedId, viewModel.user.id == session.dbUser.id{
                    viewModel.followingIds.append(newId)
                    
                }
                
                session.userViewModel.dbUser?.followingNumber += 1
                selectedId = nil
                actionOrderFollowers = .none
            case .unfollow:
                if let newId = selectedId, viewModel.user.id == session.dbUser.id{
                    viewModel.followingIds.removeAll{ $0 == newId}
                    
                }
                session.userViewModel.dbUser?.followingNumber -= 1
                selectedId = nil
                actionOrderFollowing = .none
            case .remove:
                if let newId = selectedId, viewModel.user.id == session.dbUser.id{
                    viewModel.followerIds.removeAll{ $0 == newId}
                    
                }
                session.userViewModel.dbUser?.followerNumber -= 1
                selectedId = nil
                actionOrderFollowing = .none
                
                
            case .none:
                actionOrderFollowing = .none
            }
            
        })
        
        
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        
        .navigationBarItems(trailing: trailingBar)
        .navigationBarBackButtonHidden(isPrimary)
        
        
        .fullScreenCover(isPresented: $presentImagePicker, content: {
            ProfileImagePickerView(selectedImage: $selectedImage)
        })
        
      
    }
    
    @ViewBuilder
    var leadingBar : some View{
        
            if path.count > 0 {
                Button {
                    
                    path.removeLast()
                    
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        
    }
    
    
    var trailingBar: some View{
        
        Group{
            
            if viewModel.isMyOwnAccount{
                
               
                    
                    
                    Button {
                        
                        
                        let value = NavigationValuegeneral(type: .setting, profileViewModel: viewModel)
                        path.append(value)
                        //path.append(NavigationValue(name: .setting, contentId: "", index: 0))
                        
                    } label: {
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(.black)
                            .scaleEffect(CGSize(width: 1.0, height: 1.5))
                    }
                    
                    
                
                
            }else{
                Button {
                    
                    showOptions = true
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(90))
                }
                
            }
        }
        
    }
    
    
    
    
    @ViewBuilder
    var avatarAndNeighbor: some View{
        
        ZStack{
            
            neighborButton
            
            HStack(alignment: .center){
                avatar
                Spacer()
                
            }
            .padding(.horizontal)
        }
    }
    
    
    @ViewBuilder
    
    var neighborButton: some View{
        
        VStack{
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.white.opacity(1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .overlay(
                    
                    neighbor
                        .offset(x: 57, y: 0)
                    ,alignment: .center
                    
                )
            
        }
    }
    
    @ViewBuilder
    var neighbor: some View{
            
            Button {
                
                
                
                let value = NavigationValuegeneral(type: .neighbors, profileViewModel: viewModel)
                path.append(value)
                
               // path.append(NavigationValue(name: .neighbors, contentId: "", index: 0))
                
            } label: {
                
                stats(text: "Neighbors", size: 130, color: .white)

            }
            
          
    }
    
    
}



