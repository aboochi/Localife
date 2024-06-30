//
//  PostButtons.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/26/24.
//

import SwiftUI

extension FeedSlideView{
    
    

    var postBottomBar: some View {
    
        
        VStack(alignment: .center){
            HStack(spacing: 5){
                
                Button(action: {
                    
                    Task{
                        if session.savedPostIds.contains(viewModel.post.id){
                            
                            session.savedPostIds.removeAll(where: {$0 == viewModel.post.id})
                            try await viewModel.unSavePost()
                            
                        }else{
                            
                            session.savedPostIds.append(viewModel.post.id)
                            HapticManager.shared.generateFeedback(of: .impact(style: .rigid), intensity: .medium)

                            try await viewModel.savePost()
                           
                        }
                    }
                    
                }, label: {
                    
                    Image(systemName: session.savedPostIds.contains(viewModel.post.id) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                        .scaleEffect(x: 1.1, y: 0.8)
                        .padding(.trailing, 10)
                        .padding(.leading, 10)
                        .frame(height: 33)
                    
                    
                        .overlay(
                            CustomCorners(radius: 25, corners: [.bottomRight, .topRight])
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                })
                
                
                
                HStack{
                    
                    Spacer()
                    HStack{
                        Button(action: {
                            
                           
                          



                            Task{
                                if viewModel.didLike {
                                    try await viewModel.unLike()
                                }else{
                                    
                                    HapticManager.shared.generateFeedback(of: .impact(style: .heavy), intensity: .strong)

                                    try await viewModel.like()
                                }
                            }
                            
                        }, label: {
                            
                            
                            Image(systemName: viewModel.didLike ? "heart" : "heart")
                                .font(.system(size: 22, weight:  viewModel.didLike ? .bold : .regular))
                                .foregroundColor(viewModel.didLike ? .white : .black)
                            
                            
                        })
                        
                        if viewModel.post.likeNumber > 0 {
                            
                            Button {
                                
                                if let user = viewModel.post.user{
                                    let value = NavigationValuegeneral(type: .liker, user: user, contentId: viewModel.post.id)
                                    path.append(value)
                                }

                                
                            } label: {
                                Text(viewModel.post.likeNumber > 0 ? "\(viewModel.post.likeNumber)" : "")
                                    .foregroundColor( viewModel.didLike ? .white :   .black)
                                    .font(.system(size: 18, weight:  viewModel.didLike ? .semibold : .regular))

                                    .padding(7)
                            }

                            

                        }
                        
                       
                    }
                    .frame(width: 80, height: 33)
                    Spacer()
                    
                }
                .frame(minWidth: 110)
                .background(CustomCorners(radius: 25, corners: [.bottomRight, .topRight, .bottomLeft, .topLeft]).fill(viewModel.didLike ? .red : .clear.opacity(0.5)))
                
                .overlay(
                    CustomCorners(radius: 25, corners: [.bottomRight, .topRight, .bottomLeft, .topLeft])
                        .stroke(viewModel.didLike ? .clear.opacity(0.5) : Color.gray.opacity(0.6), lineWidth: 1)
                )
                
                
                
                if viewModel.post.urls.count > 1 {
                    slideIndicatorView(index: $currentPage, numberOfSlides: viewModel.post.urls.count)
                        .frame(width: 60)
                    
                }
                
                
                
                HStack{
                    Spacer()
                    
                    HStack{
                        Button(action: {
                            
                            showCommentView = true
                            
                        }, label: {
                            
                            
                            Image(systemName: "message")
                            
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(.black)
                            
                            
                        })
                        .sheet(isPresented: $showCommentView, content: {
                            CommentsView(post: viewModel.post, showCaption: $showCaptionInComment)
                        })
                        
                        if viewModel.post.commentNumber > 0 {
                            
                            Text( viewModel.post.commentNumber > 0 ? "\(viewModel.post.commentNumber)" : "")
                                .font(.system(size: 18, weight:  .regular))
                                .foregroundColor(.black)
                        }
                           
                            
                    }
                    .frame(width: 80, height: 33)
                    
                    Spacer()
                    
                }
                .frame(minWidth: 120)
                
                .overlay(
                    CustomCorners(radius: 25, corners: [.bottomRight, .topRight, .bottomLeft, .topLeft])
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )
                
                
                
                Button(action: {
                    
                    showSharePostVew = true
                    
                    
                }, label: {
                    
                    Image(systemName: "arrowshape.turn.up.forward")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .frame(height: 33)
                    
                        .overlay(
                            CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft])
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                })
                .sheet(isPresented: $showSharePostVew) {
                    UsersToSendToView(sentUrl: $sentUrl)
                        .environmentObject(SharePostViewModel(currentUser: session.dbUser, shareCategory: .post, post: viewModel.post))
                        .presentationDetents(
                                            [.medium, .large],
                                            selection: $settingsDetent
                                         )
                }
                
                
                
                
            }
            .frame(width: UIScreen.main.bounds.width - 10)
            
            if viewModel.post.caption != ""{
                
                VStack{
                    
                    HStack{
                        Group{
                            Text("\(viewModel.post.user?.username ?? "Caption:") ")
                                .font(.system(size: 14, weight: .semibold))
                            
                            +
                            Text(viewModel.post.caption)
                                .font(.system(size: 14, weight: .regular))
                            
                            
                            
                        }
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundColor(.black)
               
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
                
                .background(Rectangle().fill(
                    LinearGradient(
                      gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.white.opacity(1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                )
                .padding(.horizontal, 5)
                
                
                
                .onTapGesture {
                    showCaptionInComment = true
                    showCommentView = true

                }

                
            }
        }
        .onChange(of: showCommentView) { oldValue, newValue in
            if !newValue{
                showCaptionInComment = false
            }
        }
        .onChange(of: actionOrderLikersList) { oldValue, newValue in
            if newValue == .fetch {
                print("fetch likers triggered")
                Task{
                    try await viewModel.getLikers()
                }
            }
        }
        
        
        
            
        }
    
    
}


