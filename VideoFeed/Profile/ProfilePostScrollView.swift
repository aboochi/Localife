//
//  SwiftUIView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/1/24.
//

import SwiftUI

enum PostTypeEnum{
    case profile
    case saved
}


protocol PostProviderProtocol: ObservableObject {
    var posts: [Post] { get set }
}


struct ProfilePostScrollView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    let screenWidth = UIScreen.main.bounds.width
    @State var appearedPostIndecis: [Int] = [-2, -1, 0, 1, 2]
    @State var playedPostIndex: Int = 0
    @State var scrollTo: String
  
    @State var zoomedPost: String = ""
    @Binding var path: NavigationPath
    let postType: PostTypeEnum

    
    var body: some View {
        
        
        
        ScrollViewReader{ proxy in
            
            ScrollView(showsIndicators: false) {
        
                VStack {
                    
                    
                    
                    ForEach(Array(posts().enumerated()), id: \.element.id) { index, post in
                        
                       

                        FeedSlideView(viewModel: FeedCellViewModel(post: post, currentUser: session.dbUser),  appearedPostIndecis: $appearedPostIndecis, playedPostIndex: $playedPostIndex, postIndex: index, zoomedPost: $zoomedPost , isZooming: .constant(false) , sentUrl: .constant("") , path: $path, isPrimary: false , isCommentExpanded: .constant([post.id: false]))
                                .frame(width: screenWidth, height: (screenWidth / max(post.aspectRatio, 0.65)) )
                                .padding(.bottom, 200)
                                .padding(.top, 20)
                                .id(post.id)
                                .zIndex(zoomedPost == post.id ? 1 : 0)

                                
                                .onAppear{
                                    print("post id for index \(index): \(post.id)  ")
                                }
                            
                                .background(
                                    GeometryReader{ geo in
                                        Color.clear
                                            .onChange(of: geo.frame(in: .global)) { oldValue, newValue in
                                                
                                                
                                                
                                                if newValue.minY > -100 && newValue.maxY < 1200 {
                                                    
                                                    playedPostIndex = index
                                                    
                                                    
                                                }
                                                
                                                if (index - 2) % 3 == 0 && appearedPostIndecis[2] != index && newValue.minY < 900 && newValue.maxY > -50 {
                                                    
                                                    withAnimation{
                                                        appearedPostIndecis  = [ index-2, index-1, index, index+1, index+2]
                                                    }
                                                    
                                                    if (viewModel.posts.count - 3...viewModel.posts.count - 1).contains(index) {
                                                        
                                                        Task{
                                                            
                                                            try await viewModel.fetchPost()
                                                            
                                                        }
                                                    }
                                                    
                                                    
                                                }
                                                
                                                
                                                
                                            }
                                        
                                    }
                                    
                                )
                        
                        
                    }
                }
                .onAppear{
                    print("scrollTo: >>>>>>>>>>>>>>>>>>>\(scrollTo)")

                    proxy.scrollTo(scrollTo, anchor: .center)
                }
                
                
            }
        }
      
    }
    
    func posts() -> [Post]{
        switch postType {
        case .profile:
            return viewModel.allPosts
        case .saved:
            return viewModel.savedPosts
        }
    }
}


