//
//  ListPeopleView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/24/24.
//

import SwiftUI


enum FollowActionOrder{

    case fetchMore
    case fetch
    case follow
    case unfollow
    case remove
    case none
}


struct ListPeopleView: View {
    @StateObject var viewModel: ListPeopleViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    let userType: UserTypeEnum
    let contentId: String?
    let comment: Comment?
    @Binding var path: NavigationPath
    
  



    init(viewModel: ListPeopleViewModel, userType: UserTypeEnum, contentId: String?, comment: Comment? = nil, path: Binding<NavigationPath>) {
        self._viewModel = StateObject(wrappedValue: viewModel) 
        self.userType = userType
        self.contentId = contentId
        self.comment = comment
        self._path = path
    }
    

    
    var body: some View {
            VStack{
                ScrollView{
                    ForEach(users(), id: \.id){ user in
                        
                        if let username = user.username{
                            HStack{
                                NavigationLink {
                                    
                                    ProfileView(viewModel: ProfileViewModel(user: user, currentUser: session.dbUser) , listingViewModel: ListingViewModel(user: user), path: $path , isPrimary: false)
                                        .environmentObject(session)
                                    
                                    
                                    
                                } label: {
                                    PersonDisplayCell(user: user, username: username, userType: userType)
                                        .environmentObject(viewModel)

                                    
                                    
                                }
                                
                                
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                }
            }
        
        
        .onAppear{
            Task{
                print("list people appeared >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
                try await fetch()
            }
        }
    
    }
    
    func users() -> [DBUser]{
        
        switch userType {
        case .follower:
            return viewModel.followers
        case .following:
            return viewModel.followings
        case .neighbor:
            return viewModel.neighbors

        case .postLiker:
            return viewModel.postLikers
        case .commentLiker:
            return viewModel.commentLikers
        case .replyLiker:
            return viewModel.replyLikers
        }
    }
    
    func fetch() async throws{
        
        Task{
            switch userType {
            case .follower:
                try await viewModel.getFollowers()
            case .following:
                try await viewModel.getFollowing()
            case .neighbor:
                try await viewModel.getNeighbors()
                
            case .postLiker:
                if let postId = contentId{
                    try await viewModel.getPostLikers(postId: postId)
                }

            case .commentLiker:
                if let comment = comment{
                    try await viewModel.getCommentLikers(comment: comment)
                }
            case .replyLiker:
                if let reply = comment, let parentCommentId = reply.parentCommentId{
                    try await viewModel.getReplyLikers(reply: reply)
                }
            }
        }
    }
    
    func refresh() async throws{
        
        Task{
            switch userType {
                
            case .follower:
                print("")
            case .following:
                print("")
            case .neighbor:
                print("")
            case .postLiker:
                print("")
            case .commentLiker:
                print("")
            case .replyLiker:
                print("")
            }
        }
        
    }
   
}

struct PersonDisplayCell: View {
    
    let user: DBUser
    let username: String
    let userType: UserTypeEnum
    @State var followedByYou: Bool = false
    @State var followingYou: Bool = false
    @State var youRequested: Bool = false
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ListPeopleViewModel
    
    
    var body: some View {
      
     
        
        let size: CGFloat = 35
        
        HStack{
            
            HStack(alignment: .center){
                AvatarView(photoUrl: user.photoUrl, username: username, size: size)
                Text(username)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                
                
            }
            
            Spacer()
            
            
            if session.dbUser.id != user.id{
                
                if viewModel.user.id == session.dbUser.id && userType == .follower{
                    
                    removeMyFollower(user: user)
                    
                }else if viewModel.user.id == session.dbUser.id && userType == .following{
                    
                    removeMyFollowing(user: user)
                    
                }else{
                    
                    people(user: user)
                }
            }
            
            
        }
        .onAppear{
            
            followedByYou = user.followedByYou ?? false
            followingYou = user.followingYou ?? false
            youRequested = user.youRequested ?? false
        }
        
        
    }
    

    
  @ViewBuilder
    func removeMyFollower(user: DBUser) -> some View{
    
   
        
        Button(action: {
            Task{
                
                try await viewModel.removefollower(followerId: user.id, followedId: session.dbUser.id)
                viewModel.followers.removeAll(where: {$0.id == user.id})
            }
            
        }, label: {
            Text("Remove")
                .padding(10)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 80)
                .background(.gray)
                .cornerRadius(10)
        })
    }
    
    @ViewBuilder
    func removeMyFollowing(user: DBUser) -> some View{
        
        Button(action: {
            Task{
                
                try await viewModel.removefollower(followerId: session.dbUser.id, followedId: user.id)
                viewModel.followings.removeAll(where: {$0.id == user.id})
                
            }
            
        }, label: {
            Text("Unfollow")
                .padding(10)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 80)
                .background(.gray)
                .cornerRadius(10)
        })
        
    }
    
    
    @ViewBuilder
    func people(user: DBUser) -> some View{
        
            
            
            Button(action: {
                
                if followedByYou{
                    
                    followedByYou = false
                    Task{
                        try await viewModel.unfollow(currentUser: session.dbUser, user: user)
                    }
                } else if !youRequested{
                    
                    if user.privacyLevel == PrivacyLevel.publicAccess.rawValue{
                        
                        followedByYou = true
                        Task{
                            try await viewModel.follow(currentUser: session.dbUser, user: user)
                        }
                        
                    }else{
                        youRequested = true
                        Task{
                            try await viewModel.request(currentUser: session.dbUser, user: user)
                        }
                    }
                    
                }
                
            }, label: {
                Text(followedByYou ? "Following": youRequested ? "Requested" : (followingYou ? "Follow back" :"Follow") )
                    .padding(10)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 100)
                    .background(.blue)
                    .cornerRadius(10)
            })
            
       
    }
    
}
        
    




