//
//  FeedViewNavigationExtension.swift
//  Localife
//
//  Created by Abouzar Moradian on 6/27/24.
//

import SwiftUI


enum NavigationDestinationTypeEnum{
    
    case notification
    case profile
    case search
    case liker
    case setting
    case followers
    case following
    case neighbors
    case editProfile
    case postExplore
    case listingExplore
    case yourListing
    case yourInterest
    case mapListing
    case smallCell
    case keywordSearch
    case post
    case listing
    case commentLiker
    case questionLiker
    case chatbox
}

struct NavigationValuegeneral : Hashable{
    let type: NavigationDestinationTypeEnum
    let user: DBUser?
    let post: Post?
    let comment: Comment?
    let question: Question?
    let listing: Listing?
    let profileViewModel: ProfileViewModel?
    let listingViewModel: ListingViewModel?
    let messageViewModel: MessageViewModel?
    let chatViewModel: ChatViewModel?


    let index: Int?
    let contentId: String?
    let userId: String?
    
    
    
    static func == (lhs: NavigationValuegeneral, rhs: NavigationValuegeneral) -> Bool {
            return lhs.type == rhs.type &&
                
                lhs.index == rhs.index &&
                lhs.contentId == rhs.contentId &&
                lhs.user == rhs.user &&
                lhs.post == rhs.post &&
                lhs.comment == rhs.comment &&
                lhs.question == rhs.question &&
                lhs.listing == rhs.listing &&
                lhs.userId == rhs.userId &&
                lhs.profileViewModel === rhs.profileViewModel &&
                lhs.listingViewModel === rhs.listingViewModel &&
                lhs.chatViewModel === rhs.chatViewModel &&
                lhs.messageViewModel === rhs.messageViewModel


        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(type)
            hasher.combine(index)
            hasher.combine(contentId)
            hasher.combine(user)
            hasher.combine(post)
            hasher.combine(comment)
            hasher.combine(question)
            hasher.combine(listing)
            hasher.combine(userId)
            if let profileViewModel = profileViewModel {
                hasher.combine(ObjectIdentifier(profileViewModel))
            }
            if let listingViewModel = listingViewModel {
                hasher.combine(ObjectIdentifier(listingViewModel))
            }
            if let messageViewModel = messageViewModel {
                hasher.combine(ObjectIdentifier(messageViewModel))
            }
            if let chatViewModel = chatViewModel {
                hasher.combine(ObjectIdentifier(chatViewModel))
            }
        }
    
    
 
   
    init(type: NavigationDestinationTypeEnum, user: DBUser? = nil, post: Post? = nil, comment: Comment? = nil, question: Question? = nil, listing: Listing? = nil, profileViewModel: ProfileViewModel? = nil, listingViewModel: ListingViewModel? = nil, messageViewModel: MessageViewModel? = nil, chatViewModel: ChatViewModel? = nil, index: Int? = nil, contentId: String? = nil, userId: String? = nil) {
        self.type = type
        self.user = user
        self.post = post
        self.comment = comment
        self.question = question
        self.listing = listing
        self.profileViewModel = profileViewModel
        self.listingViewModel = listingViewModel
        self.messageViewModel = messageViewModel
        self.chatViewModel = chatViewModel
        self.index = index
        self.contentId = contentId
        self.userId = userId
        
    }
}

struct Navigationmodifier: ViewModifier{
    
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding var path: NavigationPath
    //let value: NavigationValuegeneral
    
    func body(content: Content) -> some View {
       
        
        content
            .navigationDestination(for: NavigationValuegeneral.self) { value in
                
                switch value.type {
                case .notification:
                    
                    
                    NotificationView(path: $path)
                        .environmentObject(NotificationViewModel(currentUser: session.dbUser))
                        .environmentObject(session)
                    
                case .profile:
                    
                    if let uid = value.user?.id{
                        let user = DBUser(uid: uid, username: "placeholder")
                        ProfileView(viewModel: ProfileViewModel(user: user, currentUser: session.dbUser), listingViewModel : ListingViewModel(user: user),   path: $path , isPrimary: false)
                        
                            .environmentObject(session)
                    }
                    
                case .search:
                    content
                    
                case .liker:
                    
                    if let user = value.user{
                        
                        ListPeopleView(viewModel: ListPeopleViewModel(currentUser: session.dbUser, user: user), userType: .postLiker, contentId: value.contentId,  comment: value.comment,  path: $path)
                            .environmentObject(session)
                        
                    }
                    
                case .setting:
                    
                    if let viewModel = value.profileViewModel{
                        SettingView1()
                            .environmentObject(session)
                            .environmentObject(viewModel)
                    }
                    
                case .followers:
                    
                    if let user = value.user{
                        
                        ListPeopleView(viewModel: ListPeopleViewModel(currentUser: session.dbUser, user: user), userType: .follower, contentId: value.contentId, path: $path)
                            .environmentObject(session)
                        
                    }
                    
                case .following:
                    
                    
                    if let user = value.user{
                        
                        ListPeopleView(viewModel: ListPeopleViewModel(currentUser: session.dbUser, user: user), userType: .following, contentId: value.contentId, path: $path)
                            .environmentObject(session)
                        
                    }
                    
                    
                case .neighbors:
                    
                    if let viewModel = value.profileViewModel{
                        NeighborProfileView(path: $path, accountOwner: viewModel.user)
                            .environmentObject(session)
                            .environmentObject(viewModel)
                    }
                    
                case .editProfile:
                    
                    if let viewModel = value.profileViewModel{
                        ProfileEditView()
                            .environmentObject(session)
                            .environmentObject(viewModel)
                    }
                    
                case .postExplore:
                    
                    if let viewModel = value.profileViewModel, let index = value.index, let postId = value.contentId{
                        ProfilePostScrollView(appearedPostIndecis: [index-2, index-1, index, index+1, index+2], scrollTo: postId , path: $path, postType: .profile )
                            .environmentObject(session)
                            .environmentObject(viewModel)
                    }
                    
                case .listingExplore:
                    
                    if let viewModel = value.profileViewModel, let listingViewModel = value.listingViewModel , let listingId = value.contentId{
                        
                        ListingScrollWrapper(scrollTo: listingId, userId: viewModel.user.id, listingType: .otherUser, path: $path) { scrollTo, userId, listingType, path in
                        
                        ListingScrollViewGeneral(scrollTo: scrollTo, userId: userId, listingType: listingType, path: path)
                        
                    }
                        .environmentObject(listingViewModel)
                }
                case .yourListing:
                    
                    if let listingViewModel = value.listingViewModel, let messageViewModel = value.messageViewModel{
                        UserListingView( path: $path)
                            .environmentObject(session)
                            .environmentObject(listingViewModel)
                            .environmentObject(messageViewModel)
                    }
                case .yourInterest:
                    if let listingViewModel = value.listingViewModel{
                        ListingInterestedView( path: $path)
                            .environmentObject(listingViewModel)
                    }
                case .smallCell:
                    if let listingViewModel = value.listingViewModel, let listingId = value.listing?.id, let userId = value.listing?.ownerUid{
                        ListingScrollWrapper(scrollTo: listingId, userId: userId, listingType: .explore, path: $path) { scrollTo, userId, listingType, path in
                            
                            ListingLazyScrollView(scrollTo: scrollTo, userId: userId, listingType: listingType, path: path)
                            
                        }
                        .environmentObject(listingViewModel)
                    }
                case .keywordSearch:
                    
                    if let listingViewModel = value.listingViewModel, let listingId = value.listing?.id, let userId = value.listing?.ownerUid{
                        ListingScrollWrapper(scrollTo: listingId, userId: userId, listingType: .keywordSearch, path: $path) { scrollTo, userId, listingType, path in
                            
                            ListingLazyScrollView(scrollTo: scrollTo, userId: userId, listingType: listingType, path: path)
                            
                        }
                        .environmentObject(listingViewModel)
                    }
                case .mapListing:
                    
                    
                    if let listing = value.listing, let user = value.user, let listingViewModel = value.listingViewModel{
                        ListingScrollWrapper(scrollTo: listing.id, userId: user.id, listingType: .main, path: $path) { scrollTo, userId, listingType, path in
                            
                            ListingScrollViewGeneral(scrollTo: scrollTo, userId: userId, listingType: listingType, path: path)
                            
                        }
                        .environmentObject(listingViewModel)
                    }
                case .post:
                    
                    if let post = value.post{
                        FeedSlideView(viewModel: FeedCellViewModel(post: post, currentUser: session.dbUser), appearedPostIndecis: .constant([0]), playedPostIndex: .constant(0), postIndex: 0, zoomedPost: .constant("") , isZooming: .constant(false), sentUrl: .constant("") , path: .constant(NavigationPath()), isPrimary: false, isCommentExpanded: .constant([post.id: false]))
                            .environmentObject(session)
                    }
                case .listing:
                    
                    if let listing = value.listing, let user = listing.user {
                        ListingCoverCell(listing: listing, path: $path, appearedPostIndecis: .constant([0]), playedPostIndex: .constant(0), currentItemIndex: 0)
                    }
                case .commentLiker:
                    
                    if let comment = value.comment{
                        let user = DBUser(uid: "")
                        let userType: UserTypeEnum = comment.parentCommentId == nil ? .commentLiker : .replyLiker
                        
                        ListPeopleView(viewModel: ListPeopleViewModel(currentUser: session.dbUser, user: user), userType:  userType, contentId: value.contentId,  comment: comment,  path: $path)
                            .environmentObject(session)
                        
                    }
                case .chatbox:
                    
                    if let chatViewModel = value.chatViewModel{
                        ChatBoxView(chatClosed: .constant(""), closeNewMessage: .constant(false), path: $path)
                            .environmentObject(chatViewModel)
                            .environmentObject(session)
                    }
                case .questionLiker:
                    
                    if let question = value.question{
                        let user = DBUser(uid: "")
                        let userType: UserTypeEnum = question.parentQuestionId == nil ? .questionLiker : .questionReplyLiker
                        
                        ListPeopleView(viewModel: ListPeopleViewModel(currentUser: session.dbUser, user: user), userType:  userType, contentId: value.contentId,  question: question,  path: $path)
                            .environmentObject(session)
                        
                    }
                }
                
           
            }
        
        
        
    }
}
