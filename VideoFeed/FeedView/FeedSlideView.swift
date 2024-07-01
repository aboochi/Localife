//
//  FeedSlideView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/1/24.
//

import SwiftUI
import AVFoundation
import Kingfisher


enum FeedNavigationType{
    case profile
    case none
}

struct FeedSlideView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @StateObject var viewModel: FeedCellViewModel
    @Binding var appearedPostIndecis: [Int]
    @Binding var playedPostIndex: Int
    let postIndex: Int
    @State var currentPage : Int = 0
    let screenWidth = UIScreen.main.bounds.width
    @State var showCommentView: Bool = false
    @State var showCaptionInComment: Bool = false
    @State var actionOrderLikersList: FollowActionOrder = .none
    @State var showSharePostVew : Bool = false
    @State  var settingsDetent = PresentationDetent.medium

    @State  var currentZoom = 1.0
    @State var anchorPoint: UnitPoint = .center

    @Binding var zoomedPost: String
    @Binding var isZooming: Bool
    @Binding var sentUrl: String?
    @State var showMoreOptions: Bool = false
    @Binding var path: NavigationPath
    let isPrimary: Bool
    
    @Binding var isCommentExpanded: [String: Bool]
    
    @State var isCaptionExpanded: Bool = false

  
    var body: some View{
        
        VStack{
        
            VStack{
                
                Group{
                    
                    postHeader
                    
                    Group{
                        
                        if appearedPostIndecis.contains(postIndex){
                            
                            if viewModel.post.urls.count > 1{
                                postSlide
//                                
//                                    .onAppear{
//                                        Task{
//                                            if session.dbUser.lastSeenPostTime.dateValue() < viewModel.post.time.dateValue(){
//                                                session.dbUser.lastSeenPostTime = viewModel.post.time
//                                                try await viewModel.addPostSeen(postTime: viewModel.post.time)
//                                            }
//                                        }
//                                    }
                                
                                   
                                   
                            } else {
                                PostSingleDisplayView( post: viewModel.post, index: 0, playedPostIndex: $playedPostIndex , postIndex: postIndex, currentPage: $currentPage)
//                                    .onAppear{
//                                        Task{
//                                            if session.dbUser.lastSeenPostTime.dateValue() < viewModel.post.time.dateValue(){
//                                                session.dbUser.lastSeenPostTime = viewModel.post.time
//                                                try await viewModel.addPostSeen(postTime: viewModel.post.time)
//                                            }
//                                        }
//                                    }
                                
                            }
                            
                        }else{
                            
                            Rectangle()
                                 .foregroundColor(.white)
                                 .frame(width: screenWidth, height: (screenWidth / max(viewModel.post.aspectRatio, 0.65)) )

                        }
                    }
                   
                    //.scaleEffect(currentZoom , anchor: anchorPoint)
                    //.modifier(ZoomModifier(currentZoom: $currentZoom, anchorPoint: $anchorPoint))
                    .overlay(
                        Group{
                            if session.dbUser.hiddenPostIds.contains(viewModel.post.id){
                                Text("This post has been hidden as you requested. It won't appear in your feed anymore.")
                                    .foregroundColor(.black)
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding()
                                    .background(.white)
                                    .cornerRadius(15)
                                    .padding()
                              
                            }
                        }
                    )
                   
               
                }
                .zIndex(currentZoom > 1 ? 1: 0)
                postBottomBar
            }
          //  .frame(width: screenWidth, height: (screenWidth / max(viewModel.post.aspectRatio, 0.65)) + 100)
       
        }
       
        .onChange(of: currentZoom) { oldValue, newValue in
            if zoomedPost != viewModel.post.id, newValue > 1{
                
                zoomedPost = viewModel.post.id
                isZooming = true

            }else{
                if currentZoom == 1{
                    isZooming = false
                    zoomedPost = ""
                }
            }
        }
                
    }
    
   
    var postHeader: some View{
        HStack{
            
                
                Button {
                    if let user = viewModel.post.user{
                        
                        let value = NavigationValuegeneral(type: .profile, user: user)
                        path.append(value)
                    }
                }
            label:{
                headerLabel
            }
       
            
            Spacer()
            
            Button {
                showMoreOptions = true
                
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.black)
                    .rotationEffect(.degrees(90))
                    .padding(.horizontal, 7)
                    .padding(.vertical)
            }
            .sheet(isPresented: $showMoreOptions, content: {
                if let user = viewModel.post.user{
                    
                    RestrictionOptionsView(viewModel: ProfileViewModel(user: user, currentUser: session.dbUser), showOptions: $showMoreOptions, contentCategory: .post, contentId: viewModel.post.id, listing: nil, postCaption: viewModel.post.caption)
                        .environmentObject(session)
                        //.environmentObject(ProfileViewModel(user: user, currentUser: session.dbUser))
                        .presentationDetents([viewModel.post.ownerUid == session.dbUser.id ?   .height(180) :  .height(270)])
                    
                }
            })
           
        }
    }
    
 
        
    var postSlide: some View{
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(viewModel.post.urls.enumerated()), id: \.offset) { index, url in

                    GeometryReader{ geo in
                        ZStack{
                            
                            if index == currentPage || index == currentPage + 1 || index == currentPage - 1{
                                PostSingleDisplayView( post: viewModel.post, index: index, playedPostIndex: $playedPostIndex, postIndex: postIndex, currentPage: $currentPage)
                                    
                            } else{
                                Rectangle()
                                    .foregroundColor(.white)
                                    .frame(width: screenWidth, height: screenWidth / max(viewModel.post.aspectRatio, 0.65))
                            }
                            
                        }
                        
                            .onChange(of: geo.frame(in: .global)) { oldValue, newValue in
                                
                                
                                if newValue.midX < 0 {
                                    if currentPage == index{
                                        currentPage+=1
                                    }
                                    
                                } else if newValue.midX > geo.size.width {
                                    if currentPage == index{
                                        currentPage-=1
                                    }
                                }
                            }
                            
                    }
                }
                .frame(width: screenWidth, height: screenWidth / max(viewModel.post.aspectRatio, 0.65))

            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .scrollTargetBehavior(.paging)

        
    }
        
      
    var headerLabel: some View{
        
        HStack(alignment: .top) {
            AvatarView(photoUrl: viewModel.post.user?.photoUrl, username: viewModel.post.user?.username , size: 40)
            
            VStack(alignment: .leading, spacing: 2){
                Text(viewModel.post.user?.username ?? "")
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .semibold))
                HStack{
                    
                    Text("Neighbor")
                        .padding(.trailing, 5)
                    
                    
                    Text(viewModel.getTime())
                    
                }
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .light))
            }
            
           
        }
        .padding([.leading, .bottom, .top], 5)
    }
    
    @ViewBuilder
    var profileNavigation: some View{
        
        if let user = viewModel.post.user{
            ProfileView(viewModel: ProfileViewModel(user: DBUser(uid: user.id, username: "placeholder"), currentUser: session.dbUser),  listingViewModel: ListingViewModel(user: user), path: $path , isPrimary: false)
            
                .environmentObject(session)
                

        }
    }
        
    

}



            
                        

        
    
    
    
    



