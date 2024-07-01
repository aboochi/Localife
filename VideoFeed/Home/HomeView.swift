//
//  HomeView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/19/24.
//






import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @StateObject var viewModel : HomeViewModel
    @State var selection: Int = 0
    @State var previousSelection: Int = 0
    @State var showPostView: Bool = false
    @State var uploadCompletedSteps: CGFloat = -1
    @State var uploadAllSteps: CGFloat = 0
    @State var uploadedPostId: String?
    @State var scrollToTop: Bool = false
    @State var showStorySlide = false
    @State var storyUserIndex: Int = 0
    @State  var storyAnchorPoint: UnitPoint = .center
    @State var parentTabSelection: Int = 0
    @State private var offset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State var path: NavigationPath = NavigationPath()
    @State var marketPath: NavigationPath = NavigationPath()
    @State var profilePath: NavigationPath = NavigationPath()
    @State var mapPath: NavigationPath = NavigationPath()



    @ObservedObject  var homeIndex = HomeIndex.shared
    
    var body: some View {
        
    
        GeometryReader { geometry in
            VStack {
                ZStack {
                    
                    
                    TabView(selection: $selection.onUpdate{ oldValue, newValue in  updateNavigation(oldValue: oldValue, newValue: newValue)  }){
                        
                        NavigationStack(path: $path){
                            FeedView(uploadCompletedSteps: $uploadCompletedSteps, uploadAllSteps: $uploadAllSteps, uploadedPostId: $uploadedPostId, scrollToTop: $scrollToTop, showStorySlide: $showStorySlide, storyUserIndex: $storyUserIndex, storyAnchorPoint: $storyAnchorPoint, path: $path)
                                .environmentObject(viewModel.feedViewModel)
                            
                        }
                        
                        .tabItem { Image(systemName: "house")}
                        .tag(0)
                        .toolbar( .automatic, for: .tabBar)
                        
                        NavigationStack(path: $marketPath){
                            MarketView(viewModel: viewModel.listingViewModel, path: $marketPath)
                                .environmentObject(session)
                                .environmentObject(viewModel.MessageviewModel)

                        }
                        .tabItem { Image(systemName: "tag.fill") }
                        .tag(1)
                        PostPlaceholderView()
                            .tabItem {Image(systemName: "plus.app")
                                    .imageScale(.large)
                            }
                            .tag(2)
                        
                        NavigationStack(path: $mapPath){
                            MapView(path: $mapPath)
                                .environmentObject(viewModel.mapViewModel)
                                .environmentObject(viewModel.listingViewModel)
                        }
                        
                        .tabItem { Image(systemName: "map") }
                        .tag(3)
                    
                        NavigationStack(path: $profilePath){
              

                            ProfileView(viewModel: ProfileViewModel(user: session.dbUser, currentUser: session.dbUser), listingViewModel: ListingViewModel(user: session.dbUser), path: $profilePath,  isPrimary: true)
                                .environmentObject(session)
                                
                        }
                        .tabItem {Image(systemName: "person") }
                        
                        .tag(4)
                        
                    }
                   
                  
                    
                    .offset(x: CGFloat(homeIndex.currentIndex) * -geometry.size.width + offset + dragOffset)
                        .frame(width: geometry.size.width)
                    
                    MessageView()
                        .environmentObject(viewModel.MessageviewModel)
                        .environmentObject(session)
                    
                        .offset(x: CGFloat(homeIndex.currentIndex - 1) * -geometry.size.width + offset + dragOffset)
                        .frame(width: geometry.size.width)
                }
                .animation(.easeInOut, value: homeIndex.currentIndex)
                
                .onChange(of: homeIndex.currentIndex) { oldValue, newValue in
                    print("HomeIndex.shared.currentIndex changed >>>>>>>> \(homeIndex.currentIndex)" )
                }
         
                
            }
        }
            
   
        .overlay{
            
            if showStorySlide {
                StoryPagingView(viewModel: viewModel.feedViewModel.storyViewModel, currentUserIndex: $storyUserIndex, showStorySlide: $showStorySlide)
                   // .edgesIgnoringSafeArea(.all)
                    .transition(.scale(scale: 0, anchor: storyAnchorPoint))
                    
            }
        }
        
        
        .edgesIgnoringSafeArea(.all)
        
        
        
        .onChange(of: selection){ old, new in
            if selection != 2 {
                previousSelection = selection
                if viewModel.completedUploadingSteps == -1{
                    viewModel.imagePickerViewModel = nil
                }
            } else{
                if  viewModel.imagePickerViewModel == nil{
                    viewModel.imagePickerViewModel = ImagePickerViewModel()
                }
                
                showPostView = true
            }
        }
        .onChange(of: viewModel.completedUploadingSteps, { oldValue, newValue in
            
            let count = viewModel.numberOfSelectedAssets
            let steps = CGFloat((count * 2) + 1)
            self.uploadCompletedSteps = newValue
            self.uploadAllSteps = steps
            
            print("inside onchange completed steps: >>>>>>>>>>>>>>>> \(newValue)")
            print("all steps: >>>>>>>>>>>>>>>> \(steps)")
            
            if newValue == steps{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
                    viewModel.imagePickerViewModel = nil
                    viewModel.completedUploadingSteps = -1
                    viewModel.numberOfSelectedAssets = 0
                    
                }
                
            }
        })
        .onChange(of: viewModel.uploadedPostId, { oldValue, newValue in
            if let newValue = newValue{
                uploadedPostId = newValue
            }
        })
        .fullScreenCover(isPresented: $showPostView, content: {
            PostImagePickerView(selection: $selection, previousSelection: previousSelection, showPostView: $showPostView)
                .environmentObject(viewModel.imagePickerViewModel ?? ImagePickerViewModel() )
        })
        
    }
    
   
}




