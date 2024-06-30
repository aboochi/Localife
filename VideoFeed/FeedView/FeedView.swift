//
//  FeedViewTest.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/26/24.
//


import SwiftUI
import AVFoundation
import Kingfisher

struct FeedView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel : FeedViewModel
    @Binding var uploadCompletedSteps: CGFloat
    @Binding var uploadAllSteps: CGFloat
    @Binding var uploadedPostId: String?
    @Binding var scrollToTop: Bool
    @State var playedPostIndex: Int = 0
    @State var hideNavigationBar: Bool =  false
    @State var appearedPostIndecis: [Int] = [-2, -1, 0, 1, 2]
    @Binding var showStorySlide: Bool
    @Binding var storyUserIndex: Int
    @Binding  var storyAnchorPoint: UnitPoint
    
    
    @Binding var path: NavigationPath
    @ObservedObject  var homeIndex = HomeIndex.shared
    
    @State var searchText: String = ""
       
    @State var zoomedPost: String = ""
    @State var isZooming: Bool = false
    @State var sentUrl: String? = nil
    @State var showSentThumbnail: Bool = false
    @State var xOffset: CGFloat = 0
    @State var yOffset: CGFloat = 0
    @State var width: CGFloat = 70
    @State var height: CGFloat = 70
    @State var isAnimating: Bool = false

    @State var isCommentExpanded: [String: Bool] = [:]


    let screenWidth = UIScreen.main.bounds.width

    var body: some View {
        
      
            ScrollViewReader{ proxy in
                
                ScrollView(showsIndicators: false) {
                    VStack{
                        
                     
                        UploadProgressBar(uploadAllSteps: uploadAllSteps, uploadCompletedSteps: uploadCompletedSteps)
                           
                            .id(-1)
                        
                        
                        VStack {
                            ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                                
                                    
                                    FeedSlideView(viewModel: FeedCellViewModel(post: post, currentUser: session.dbUser),  appearedPostIndecis: $appearedPostIndecis, playedPostIndex: $playedPostIndex, postIndex: index, zoomedPost: $zoomedPost , isZooming: $isZooming, sentUrl: $sentUrl, path: $path,  isPrimary: true , isCommentExpanded: $isCommentExpanded)
                                    .padding(.bottom, 20)
                                    .id(post.id)
                                    .zIndex(zoomedPost == post.id ? 1 : 0)
                                
                                  
                                    .modifier(Lazymodifier(playedPostIndex: $playedPostIndex, appearedPostIndecis: $appearedPostIndecis, isNotTop: .constant(true), index: index, action: {
                                        //session.postSeenIds.append(post.id)
                                        
                                    }))
                                
                                

                          
                                
                            }
                         
                        }
                        .padding(.top, 20)

                        .modifier(Navigationmodifier(path: $path))
                        

                        
                        .onChange(of: path.count, { oldValue, newValue in
                            if newValue > oldValue{
                                
                                homeIndex.feedViewIsAppear = false
                            }else{
                                homeIndex.feedViewIsAppear = true

                            }
                        })
                       
                       
                        .onChange(of: scrollToTop) { oldValue, newValue in
                            if newValue{
                                
                                withAnimation{
                                    proxy.scrollTo(-1, anchor: .top)
                                    appearedPostIndecis  = [ -2, -1, 0, 1, 2]
                                }
                                appearedPostIndecis  = [ -2, -1, 0, 1, 2]
                               
                                scrollToTop = false
                            }
                        }
                        
                        
                        .onChange(of: appearedPostIndecis, { oldValue, newValue in
                            
                            
                            if newValue.contains(viewModel.posts.count - 1){
                                Task{
                                    print("appeared posts: >>>>\(newValue)                 viewModel.posts.count - 1  >>>>>>>>>\(viewModel.posts.count - 1)"    )

                                    try await viewModel.fetchPost(lastTime: session.dbUser.lastSeenPostTime)
                                    print("after >>>>>>>>>>>. viewModel.posts.count - 1  >>>>>>>>>\(viewModel.posts.count - 1)"    )
                                }
                            }
                        })
                        
     
                        
                        .onChange(of: uploadCompletedSteps) { oldValue, newValue in
                            let progress = uploadCompletedSteps / uploadAllSteps
                            print("progress: \(progress)")
                        }
                        .onChange(of: uploadedPostId) { oldValue, newValue in
                            if let uploadedPostId = uploadedPostId {
                                Task {
                                    try await viewModel.fetchPostById(postId: uploadedPostId)
                                }
                            }
                        }
                        
                        .onChange(of: sentUrl) { oldValue, newValue in
                            if let url = newValue , url.count > 0{
                                
                               
                                    showSentThumbnail = true
                                    
                                    isAnimating = true

                                    // Start the animation
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        xOffset = 180
                                        yOffset = -398
                                        width = 5
                                        height = 5
                                    }
                                    
                                    // Reset the animation state after the animation completes
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                                        isAnimating = false
                                        width = 70
                                        height = 70
                                        xOffset = 0
                                        yOffset = 0
                                        showSentThumbnail = false
                                        sentUrl = nil
                                    }
                                    
                              
                            }
                        }
                        
                        
                    }
                }
                
                
                .scrollDisabled(isZooming)

                .refreshable {
                    if viewModel.lastDocument != nil{
                        Task{
                            viewModel.posts = []
                            viewModel.lastDocument = nil
                            viewModel.updateUser(session.dbUser)
                            try await viewModel.fetchPost(lastTime: session.dbUser.lastSeenPostTime)
                        }
                    }
                }
                
        
            }
        
            .onAppear{
                
                Task{
                    session.savedPostIds = try await viewModel.getSavedPostIds()
                    session.savedListingIds = try await viewModel.getSavedListingIds()
                    session.followerIds = try await viewModel.getFollowerIds()
                    session.followingIds = try await viewModel.getFollowingIds()
                    session.requestIds = try await viewModel.getRequestIds()
                    session.postSeenIds = try await viewModel.getSeenPostIds()
                    
                    try await viewModel.fetchPost(lastTime: session.dbUser.lastSeenPostTime)

                    
                    if let firstPost = viewModel.posts.first{
                         if !session.postSeenIds.contains(firstPost.id)  {
                            session.postSeenIds.append(firstPost.id)
                            try await viewModel.addPostSeen(postId: firstPost.id)
                        }
                    }


                }
            }
        
         
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
        
            .navigationBarItems( leading: leadingBarItem, trailing:  trailingBarItem)
            .navigationBarHidden(homeIndex.isSearchExpanded)
            .edgesIgnoringSafeArea(homeIndex.isSearchExpanded ? [] : [])
            
            .overlay{
                
                if homeIndex.isSearchExpanded{
                    SearchFieldView(path: $path)
                        //.transition(.scale(scale: 0, anchor: UnitPoint(x: 20, y: 60)))
                        .environmentObject(session)
                        .environmentObject(UserSearchViewModel(user: session.dbUser))
                }
            }
        
            .overlay{
                
                if showSentThumbnail {
                    KFImage(URL(string: sentUrl!))
                        .resizable()
                        .scaledToFill()
                        
                        .frame(width: width, height: height)
                        .offset(x: xOffset, y: yOffset)
                        .animation(isAnimating ? .easeInOut(duration: 1.0) : .none, value: xOffset)
                        .animation(isAnimating ? .easeInOut(duration: 1.0) : .none, value: yOffset)
                        .animation(isAnimating ? .easeInOut(duration: 1.0) : .none, value: width)
                        .animation(isAnimating ? .easeInOut(duration: 1.0) : .none, value: height)
                        
                }
                
            
            }
       
        
        }
    
    
    @ViewBuilder
    var leadingBarItem: some View{
        
        if !homeIndex.isSearchExpanded{
            Button {
               
                    homeIndex.isSearchExpanded = true
               
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)

            }
        }

      
    }
    
    @ViewBuilder
    private var trailingBarItem: some View {
    
    HStack{
        
     
        Button {
            
            let value = NavigationValuegeneral(type: .notification)
            path.append(value)
            
        } label: {
            
                Image(systemName: "bell")
                    .foregroundColor(.black) //Color(hex: "#eae6e7")
                    //.shadow(radius: 10)
                
         
        }

       
        Button {
            homeIndex.currentIndex = 1
        } label: {
            
            Image(systemName: "ellipsis.message")
                .foregroundColor(.black)
                //.shadow(radius: 10)
                .overlay(
                    
                    Text("\(viewModel.MessageviewModel.unreadChats.count)")
                        .foregroundColor(viewModel.MessageviewModel.unreadChats.count > 0 ? .white : .clear)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(6)
                        .background(viewModel.MessageviewModel.unreadChats.count > 0 ? .red : .clear)
                        .clipShape(Circle())
                        .frame(alignment: .topTrailing)
                        .offset(x: 7, y: -11)
                    
                    
                    ,alignment: .topTrailing
                )
            
        }

        
        
            
         
        }
    }
    
    
    
    


}


