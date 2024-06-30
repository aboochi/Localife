//
//  PostShareView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/25/24.
//

import SwiftUI

struct PostShareView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ImagePickerViewModel
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    @State var tabSelection: Int = 0
    @Binding var showPostView: Bool
    @Binding var selection: Int
    @State var scale: CGFloat = 1
    @State var selectedIndex: Int?

    

    var body: some View{
        ZStack{
            if viewModel.mode == .story{
                Color.black
                    .edgesIgnoringSafeArea(.all) // Background color
            }
            
            if viewModel.mode == .post{
                ScrollView(showsIndicators: false){
                    
                    
                    VStack(){
                        
                        
                        
                        
//                        SelectedMediaScrollView(viewModel: viewModel) { index in
//                            LongTapGestureModifier {
//                                
//                                print("long press")
//                                selectedIndex = index
//                                viewModel.displayIndex = index
//                                
//                            }
//                        }
//                        .padding()
                        
                        VStack{
                            
                            VStack{
                                header
                                
                                ImagePickerSlidePreview(viewModel: viewModel)
                                    .frame(minHeight: viewModel.frameSize.height)
                                
                                
                                bottom
                            }
                            .frame(width: viewModel.frameSize.width )
                            .padding(10)
                            .background(.white)
                            .cornerRadius(5)
                            .padding(10)

                        }
                        .frame(width: screenWidth )
                        .background(.gray.opacity(0.2))
                        
                        
                        
                        captionSection
                    }
                    .frame(width: screenWidth )
                    
                    
                }
            }else {
               
                ZStack {
                    // Apply scaling to the main content
                    PostShareSlideDisplayView(viewModel: viewModel, assetItem: viewModel.selectedAssets.first!, tabSelection: $tabSelection)
                        .scaleEffect(UIScreen.main.bounds.width / viewModel.frameSize.width)
                    
                    // Overlay is positioned relative to the original size
                    VStack{
                        header
                            .padding()
                        Spacer()
                    }
                }
                   
            }
            
            if let assetIndex = selectedIndex, let uiImage = viewModel.selectedAssets[assetIndex].thumbnail {
                
                VStack(spacing: 15){
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(5)
                        .clipped()
                    
                    HStack(spacing: 15){
                        
                        Button {
                            selectedIndex = nil
                            
                            
                        } label: {
                            Text("Keep")
                        }
                        
                        
                        Button {
                            
                            viewModel.selectedAssets.remove(at: assetIndex)
                            selectedIndex = nil
                            
                        } label: {
                            Text("Delete")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(30)
                .background(.white)
                .cornerRadius(15)
                .shadow(radius: 10)
            }
        }
        
        .navigationTitle("Post Preview")
        .navigationBarItems(
            
                    
                    trailing: HStack {
                        Button(action: {
                            if viewModel.mode == .post{
                                Task{
                                    //guard let uid = session.authUser?.uid else{ throw URLError(.cannotConnectToHost)}
                                    viewModel.completedUploadingSteps = 0
                                    viewModel.numberOfSelectedItems = CGFloat(viewModel.selectedAssets.count)
                                    
                                    do{
                                        try await viewModel.savePostToFirebase(user: session.dbUser)
                                        print("Post successfully saved in firestore [from view]")
                                    } catch{
                                        viewModel.completedUploadingSteps = -2
                                        throw URLError(.badServerResponse)
                                    }
                                }
                            } else if viewModel.mode == .story{
                                Task{
                                    guard let uid = session.authUser?.uid else{ throw URLError(.cannotConnectToHost)}
                                    viewModel.completedUploadingSteps = 0
                                    viewModel.numberOfSelectedItems = CGFloat(viewModel.selectedAssets.count)
                                    do{
                                        try await viewModel.saveStoryToFirebase(uid: uid)
                                        print("Story successfully saved in firestore [from view]")
                                    } catch{
                                        throw URLError(.badServerResponse)
                                    }
                                }
                            }
                           selection = 0
                           showPostView = false

                        }) {
                            Text("Share")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                       
                    }
                )
       
    }
       
    
    
    var slide: some View{
        
        ZStack{
            
            TabView(selection: $tabSelection){
                ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element.id) { index, assetItem in
                    
                    PostShareSlideDisplayView(viewModel: viewModel, assetItem: assetItem, tabSelection: $tabSelection)
                    
                        .tag(index)
                    
                }
                
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: viewModel.selectedAssets.count > 1 ?  .always: .never))
            
            .onChange(of: tabSelection){ oldIndex, newIndex in
                
                viewModel.selectedAssets[newIndex].player?.seek(to: .zero)
                viewModel.selectedAssets[newIndex].player?.play()
                viewModel.selectedAssets[oldIndex].player?.seek(to: .zero)
                viewModel.selectedAssets[oldIndex].player?.pause()
            }
        }
        
        .frame(minHeight: viewModel.frameSize.height)
        
    }
    
    
    
    var header: some View{
        
        HStack(alignment: .top) {
            AvatarView(photoUrl: session.dbUser.photoUrl, username: session.dbUser.username , size: 30)
            
            VStack(alignment: .leading, spacing: 2){
                Text(session.dbUser.username ?? "")
                    .foregroundColor(.black)
                    .font(.system(size: 12, weight: .semibold))
                HStack{
                    
                    Text("Neighbor")
                        .padding(.trailing, 5)
                    
                    
                    Text("1s")
                    
                }
                .foregroundColor(.gray)
                .font(.system(size: 12, weight: .light))
            }
            
           Spacer()
            
            Image(systemName: "ellipsis")
                .foregroundColor(.black)
                .rotationEffect(.degrees(90))
                .padding(.horizontal, 1)
                .padding(.vertical)
        }
        .padding([.leading, .bottom, .top], 1)
    }
    
    var bottom: some View{
        
        VStack(alignment: .leading){
            
            HStack(spacing: 4){
                
                Image(systemName: "bookmark")
                    .font(.system(size: 18, weight:  .regular))
                    .scaleEffect(x: 1.1, y: 0.8)
                    .foregroundColor( .black)
                    .frame(minWidth: 40)
                    .frame(height: 25)
                    .overlay(
                        CustomCorners(radius: 25, corners: [.bottomRight, .topRight])
                            .stroke( Color.gray.opacity(0.6), lineWidth: 1)
                    )
                HStack{
                    Spacer()
                    Image(systemName: "heart")
                        .font(.system(size: 18, weight:  .regular))
                       
                        .foregroundColor( .black)
                        .frame(minWidth: 75)
                        .frame(height: 25)
                        
                    Spacer()
                }
                .overlay(
                    CustomCorners(radius: 25, corners: [.bottomRight, .topRight, .bottomLeft, .topLeft])
                        .stroke( Color.gray.opacity(0.6), lineWidth: 1)
                )
               
                HStack{
                    Spacer()
                    
                    Image(systemName: "message")
                        .font(.system(size: 18, weight:  .regular))
                        
                        .foregroundColor( .black)
                        .frame(minWidth: 75)
                        .frame(height: 25)
                       
                    Spacer()
                }
                .overlay(
                    CustomCorners(radius: 25, corners: [.bottomRight, .topRight, .bottomLeft, .topLeft])
                        .stroke( Color.gray.opacity(0.6), lineWidth: 1)
                )
                
               
                Image(systemName: "arrowshape.turn.up.forward")
                    .font(.system(size: 18, weight:  .regular))
                    
                    .foregroundColor( .black)
                    .frame(minWidth: 40)
                    .frame(height: 25)
                    .overlay(
                        CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft])
                            .stroke( Color.gray.opacity(0.6), lineWidth: 1)
                    )

            }
            .frame(width: viewModel.frameSize.width )
            .font(.system(size: 20, weight: .medium))
           .padding(.horizontal, 1)



        }
    }
    
    @ViewBuilder
    var captionSection: some View{
        
        VStack{
            TextEditor(text: $viewModel.caption)
                .frame(height: screenWidth * 0.3)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .stroke(.gray, lineWidth: 1)
                )
                .overlay(
                    Group{
                        if viewModel.caption.isEmpty{
                            Text("Write a caption...")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 5)
                                .allowsHitTesting(false)
                        }
                    }
                    ,alignment: .topLeading
                )
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 15)

    }
    
    


}







struct ImagePickerSlidePreview: View{
    @ObservedObject var viewModel: ImagePickerViewModel
    @State var tabSelection: Int = 0
    
    var body: some View{
        
        
            
            ZStack{
                
                TabView(selection: $tabSelection){
                    ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element.id) { index, assetItem in
                        
                        PostShareSlideDisplayView(viewModel: viewModel, assetItem: assetItem, tabSelection: $tabSelection)
                        
                            .tag(index)
                        
                    }
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                .onChange(of: tabSelection){ oldIndex, newIndex in
                    
                    viewModel.selectedAssets[newIndex].player?.seek(to: .zero)
                    viewModel.selectedAssets[newIndex].player?.play()
                    viewModel.selectedAssets[oldIndex].player?.seek(to: .zero)
                    viewModel.selectedAssets[oldIndex].player?.pause()
                }
            }
            
            
        }
    }






