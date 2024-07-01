//
//  QuestionsCellView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//



import SwiftUI
import Kingfisher
import SwipeActions

struct QuestionsCellView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @StateObject var viewModel: QuestionCellViewModel
    @Binding var bufferQuestion: Question?
    @Binding var actionOrder: CommentActionType
    @Binding var replySent: Bool
    @Binding var state: SwipeState
    let postOwnerUsername: String
    @State var updatedQuestionContent: String?
    @State var actionOrderLikersList: FollowActionOrder = .none
    @Binding var path: NavigationPath

    
    

    
    var body: some View {
       
            VStack(alignment: .leading){
                singleQuestionDisplay(question: viewModel.question)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    viewModel.questionCellHeight[viewModel.question.id] = proxy.size.height
                                }
                        }
                    )
                
                    .addSwipeAction(edge: .trailing,  state : $state){
                        SwipeActionButtons(question: viewModel.question)
                    }
                
                
                VStack(alignment: .leading){
                    ForEach(viewModel.replies, id: \.id){ reply in
                        
                        singleQuestionDisplay(question: reply)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                                        .onAppear {
                                            viewModel.questionCellHeight[reply.id] = proxy.size.height
                                        }
                                }
                            )
                            .addSwipeAction(edge: .trailing, state : $state){
                                SwipeActionButtons(question: reply)
                            }
                        
                        
                    }
                }
                .padding(.leading, 50)
                .onChange(of: state) { oldValue, newValue in
                    print("state old value: \(oldValue)")
                    print("state new value: \(newValue)")
                    
                }
                
                
                
                if  viewModel.question.replyNumber  - viewModel.replies.count > 0 &&  viewModel.replies.count > 0{
                    Button(action: {
                        Task{
                            try await viewModel.fetchReplies()
                        }
                    }, label: {
                        Text("View \(viewModel.question.replyNumber - viewModel.replies.count) replies")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    })
                    .padding(.leading, 60)
                    
                }
            }
                
            
            
            
            .onChange(of: replySent) { oldValue, newValue in
                
                if let reply = bufferQuestion,  reply.parentQuestionId == viewModel.question.id , newValue == true {
                    viewModel.replyDidLike[reply.id] = false
                    viewModel.likeOffset[reply.id] = 0
                    viewModel.replies.append(reply)
                    bufferQuestion = nil
                    replySent = false
                    print("viewModel.replies : \(viewModel.replies)")
                    
                }
            }
            
            .onChange(of: actionOrder) { oldValue, newValue in
                if oldValue == .edit && newValue  == .noAction{
                    
                    if let question = bufferQuestion , let _ = question.parentQuestionId  {
                        Task{
                            let updatedQuestion = try await viewModel.getReply(replyId: question.id)
                            if let index = viewModel.replies.firstIndex(where: {$0.id == updatedQuestion.id}){
                                viewModel.replies[index].content = updatedQuestion.content
                            }
                            bufferQuestion = nil
                        }
                    } else if let question = bufferQuestion, question.id == viewModel.question.id{
                        
                        Task{
                            let updatedQuestion = try await viewModel.getQuestion(question: question)
                            
                            updatedQuestionContent = updatedQuestion.content
                            
                        }
                        
                        bufferQuestion = nil
                        
                    }
                }
            }
            
            
            
            .onChange(of: actionOrderLikersList) { oldValue, newValue in
                if newValue == .fetch {
                    Task{
                        try await viewModel.getQuestionLikers()
                    }
                }
            }
     
    }
    
    
    @ViewBuilder
    func singleQuestionDisplay(question: Question) -> some View {
        HStack (alignment: .top) {
            
            NavigationLink {
                if let user = question.user{
                    ProfileView( viewModel: ProfileViewModel(user: user, currentUser: session.dbUser) , listingViewModel: ListingViewModel(user: user), path: .constant(NavigationPath()) , isPrimary: false)
                }
            } label: {
                AvatarView(photoUrl: question.user?.photoUrl, username: question.user?.username, size: 36)
            }

         
            
            
            
                VStack (alignment: .leading){
                    HStack(alignment: .center) {
                        Text(question.user?.username ?? question.questionOwnerUsername)
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text(question.timestampText ?? "")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .padding(.trailing)
            
          
                }
                if let mention = question.mentionUsername{
                    
                        
                        Text("@\(mention) ")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                           
                    
                        + Text("\(question.content)")
                            .font(.system(size: 14))
                    
                   
                    
                } else {
                    Text("\(updatedQuestionContent == nil ? question.content: updatedQuestionContent ?? question.content)")
                    
                        .font(.system(size: 14))
                }
                    
                    
                    HStack(spacing: 10){
                        replyButton(question: question)
                        numberOfLike(question: question)
                        likeButton(question: question)
                    }
                    
                
                
                    
                
                
                
                if question.parentQuestionId == nil && viewModel.question.replyNumber  > 0 && viewModel.replies.count == 0{
                    Button(action: {
                        Task{
                            try await viewModel.fetchReplies()
                        }
                    }, label: {
                        Text("View \(viewModel.question.replyNumber - viewModel.replies.count) replies")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.top, 1)
                    })
                    
                            
                        }
   
            }
     
                Spacer()
                
                
            
            
        }.padding(.horizontal)
            .foregroundColor(.black)
            
    }
    
    
    
    @ViewBuilder
    func likeButton(question: Question) -> some View{
        
        VStack {
            Button(action: {
                if question.parentQuestionId == nil{
                    if viewModel.didLike{
                        viewModel.didLike = false
                        if let offset = viewModel.likeOffset[question.id]{
                            viewModel.likeOffset[question.id] = offset - 1
                        }
                        
                        Task{
                            try await viewModel.unlikeQuestion(uid: session.dbUser.id)
                        }
                    }else {
                        viewModel.didLike = true
                        if let offset = viewModel.likeOffset[question.id]{
                            viewModel.likeOffset[question.id] = offset + 1
                        }

                        Task{
                            try await viewModel.likeQuestion(uid: session.dbUser.id)
                        }
                    }
                } else {
                    if let didLike = viewModel.replyDidLike[question.id], didLike == true{
                        viewModel.replyDidLike[question.id] = false
                        if let offset = viewModel.likeOffset[question.id]{
                            viewModel.likeOffset[question.id] = offset - 1
                        }

                        Task{
                            try await viewModel.unlikeReply(reply: question)
                        }
                    } else {
                        viewModel.replyDidLike[question.id] = true
                        if let offset = viewModel.likeOffset[question.id]{
                            viewModel.likeOffset[question.id] = offset + 1
                        }

                        Task{
                            try await viewModel.likeReply(reply: question)
                        }
                    }
                }
                
            }, label: {
                let didLike = question.parentQuestionId == nil ? viewModel.didLike : viewModel.replyDidLike[question.id]
                Image(systemName: didLike! ? "heart.fill" : "heart")
                    .font(.system(size: 14))
                    .foregroundColor(didLike! ? .red : .gray)
                
               
                    
            })

        
               
        }
    }
    
    @ViewBuilder
    func numberOfLike(question: Question) -> some View{
        
        let like = question.likeNumber +  (viewModel.likeOffset[question.id] ?? 0)
        if like > 0{
            
           
            Button {
              
                let value = NavigationValuegeneral(type: .questionLiker, question: question)
                path.append(value)
                
            } label: {
                Text("\(like) \(like > 1 ? "Likes" : "Like")")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                    .padding(.top, 1)
            }
            
            
           
        }
    }
    
    
    
    @ViewBuilder
    func replyButton(question: Question) ->some View{
        
        Button(action: {
            if question.questionOwnerId == viewModel.question.parentQuestionId{
                bufferQuestion = question
            }else{
                var newQuestion = viewModel.question
                newQuestion.setOwnerId(siblingQuestionId: question.questionOwnerId)
                newQuestion.setOwnerUsername(siblingQuestionUsername: question.questionOwnerUsername)
                newQuestion.setUserOwner(user: question.user)
                newQuestion.parentQuestionId = question.parentQuestionId
                bufferQuestion = newQuestion
                actionOrder = .reply

            }

            
        }, label: {
            Text("Reply")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.top, 1)
        })
    }
    
    
    
    
    @ViewBuilder
    func SwipeActionButtons(question: Question) -> some View{
        
        
        if session.dbUser.id == question.questionOwnerId || session.dbUser.id == question.listingOwnerId{
            
            Button {
                if question.parentQuestionId == nil {
                    bufferQuestion = question
                    actionOrder = .delete
                } else{
                    Task{
                        try await viewModel.deleteReply(reply: question)
                        if let index = viewModel.replies.firstIndex(where: {$0.id == question.id}){
                            viewModel.replies.remove(at: index)
                        }
                        
                    }
                }
                print("remove")
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: viewModel.questionCellHeight[question.id] ?? 60, alignment: .center)
            .contentShape(Rectangle())
            .background(Color.red)
        }
//        Button {
//            print("Inform")
//            state = .swiped(UUID(uuidString: question.id)!)
//
//        } label: {
//            Image(systemName: "arrow.uturn.up")
//                .foregroundColor(.white)
//        }
//        .frame(width: 60, height: viewModel.questionCellHeight[question.id] ?? 60, alignment: .center)
//        .background(Color.blue)
        
        if session.dbUser.id == question.questionOwnerId {
            
            Button {
                bufferQuestion = question
                actionOrder = .edit
                print("Edit")
                state = .swiped(UUID(uuidString: question.id)!)
                
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: viewModel.questionCellHeight[question.id] ?? 60, alignment: .center)
            .background(Color.gray)
        }
    }
}




