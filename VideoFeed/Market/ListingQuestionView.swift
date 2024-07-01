//
//  ListingQuestionViewModel.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//



import SwiftUI
import SwipeActions



struct ListingQuestionView: View {
    
    @State var questionText = ""
    @ObservedObject var viewModel: ListingQuestionViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @State var bufferQuestion: Question?
    @State var replySent: Bool = false
    @State var actionOrder: CommentActionType = .noAction
    @State var state: SwipeState = .untouched
    @FocusState private var focus: FocusableField?
    @State var path = NavigationPath()




    
    init(listing: Listing) {
        self.viewModel = ListingQuestionViewModel(listing: listing)
        
    }
    
    var body: some View {
        ZStack{
            NavigationStack(path: $path){
                VStack() {
                    Text("Questions")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .medium))
                        .padding(.top, 10)
                    Divider()
                    ScrollView {
                        
                        
                        
                        
                        LazyVStack(alignment: .leading, spacing: 24) {
                            ForEach(viewModel.questions){ question in
                                QuestionsCellView(viewModel: QuestionCellViewModel(question: question, currentUser: session.dbUser), bufferQuestion: $bufferQuestion, actionOrder: $actionOrder, replySent: $replySent, state: $state, postOwnerUsername: viewModel.listing.user?.username ?? "unknown", path: $path)
                            }
                        }
                    }
                    if let question = bufferQuestion , (actionOrder == .reply || actionOrder == .edit){
                        Divider()
                        HStack{
                            if actionOrder == .reply{
                                Text("Replying to @\(question.user?.username ?? "Deleted Account")")
                                    .foregroundColor(.black)
                            } else {
                                let description = (question.parentQuestionId == nil) ? "question" : "reply"
                                Text("Editing your \(description)")
                                    .foregroundColor(.black)
                                    .onAppear{
                                        questionText = question.content
                                    }
                            }
                            
                            Spacer()
                            Button(action: {
                                bufferQuestion = nil
                                actionOrder = .noAction
                                questionText = ""
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                
                                
                            })
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    
                    commentIput()
                }
                
                .modifier(Navigationmodifier(path: $path))

                
                .onTapGesture {
                    focus = nil
                }
                
                
                
                .onChange(of: actionOrder) { oldValue, newValue in
                    if oldValue == .noAction && newValue == .delete {
                        if let question = bufferQuestion {
                            Task{
                                try await viewModel.deleteQuestion(question: question, user: session.dbUser)
                                if let index = viewModel.questions.firstIndex(where: {$0.id == question.id}){
                                    viewModel.questions.remove(at: index)
                                    print("index of the deleted question:  ?????????????   \(index)")
                                }
                                bufferQuestion = nil
                                actionOrder = .noAction
                            }
                        }
                    }
                }
            }
            
            if viewModel.questions.count < 1{
                VStack{
                    
                    Text("No questions yet")
                    
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(10)
                    
                    Text("Be the first one")
                        .font(.system(size: 14, weight: .light))
                            .foregroundColor(.black)
                    
                    
                }
            }
        }
        
    }
    
    func uploadQuestion() async throws {
        let user = session.dbUser
        try await viewModel.addQuestion(content: questionText, user: user )
        self.questionText = ""
    }
    
    func uploadReply(question: Question) async throws {
        do{
            let user = session.dbUser
            let reply = try await viewModel.replyToQuestion(content: questionText, user: user, question: question)
            self.questionText = ""
            self.bufferQuestion = reply
            self.replySent = true
        } catch {
            bufferQuestion = nil
            throw error
        }
        
    }
    
    
    func commentIput() -> some View{
        
        
            VStack {
                Rectangle()
                    .foregroundColor(Color(.separator))
                    .frame(width: UIScreen.main.bounds.width, height: 0.8)
                
                HStack {
                    
                    
                    TextField("Question...", text: $questionText)
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 45)
                        .background(Capsule().fill(Color.white.opacity(0.3)))
                        .overlay(
                            Capsule()
                                .stroke(.gray, lineWidth: 1)
                        )
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focus, equals: .username)
                        .submitLabel(.send)
                        .onSubmit {
                            
                            if !questionText.isEmpty{
                                questionAction()
                            }
                        }
                    
                 
                    Button(action: {
                        questionAction()
                        
                    }, label: {
                        Text("Send")
                            .bold()
                            .foregroundColor(.black.opacity(questionText.isEmpty ? 0.5: 1))
                    })
                    .disabled(questionText.isEmpty)
                    
                  
                }.padding(.horizontal)
                
            }.padding(.bottom, 8)
        }
    
    
    
    
    func questionAction(){
        
        Task{
            if let question = bufferQuestion, actionOrder == .reply{
                try await uploadReply(question: question)
            }else if let question = bufferQuestion, actionOrder == .edit{
                if question.parentQuestionId == nil{
                    Task{
                        try await viewModel.editQuestion(question: question, content: questionText)
                        
                        actionOrder = .noAction
                        questionText = ""
                    }
                } else{
                    Task{
                        try await viewModel.editReply(question: question, content: questionText)
                        
                        actionOrder = .noAction
                        questionText = ""
//                                        let updatedComment = try await viewModel.getComment(comment: comment)
//                                        if let index = viewModel.comments.firstIndex(where: {$0.id == comment.id}){
//                                            viewModel.comments[index].content = updatedComment.content
//                                        }
                       


                    }
                }
                
            }else{
                Task{
                    try await uploadQuestion()
                }
            }
        }
    }
    
}
