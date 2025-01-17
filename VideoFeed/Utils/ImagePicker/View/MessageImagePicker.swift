//
//  MessageImagePicker.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/16/24.
//




import SwiftUI
import PhotosUI



struct MessageImagePickerView: View {
    
    @EnvironmentObject var viewModel : ImagePickerViewModel
    let pickerId: String
    let numberOfColumns: Int = 4
    let spacing: CGFloat = 6
    let deviceSize = UIScreen.main.bounds.size
    @State var showLimitedPicker = false
    @Environment(\.dismiss) var dismiss
    
    
    
   

    var body: some View {
        NavigationStack{
            VStack{
                HStack(alignment: .center){
                    
                    dismissButton
                    
                    Spacer()
                    
         
                    SelectedMediaScrollView(viewModel: viewModel) { index in
                        OnTapGestureModifier {
                            viewModel.displayIndex = index
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    NavigationLink {
                        
                        if viewModel.selectedAssets.count > 0 {
                            MessageShareImageView(pickerId: pickerId)
                        }
                        
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
        
                }
                .padding(.horizontal)
                

             
                
                HStack{
                    
                    
                    albumMenu
                    
                    
                    Spacer()
                    

                    addMorePhotoButton
                    
                    settingButton
                    
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
                
                
                
                ImagePickerLibraryGridView(viewModel: viewModel, spacing: spacing)
//                    .overlay(
//                        
//                        Button(action: {
//                            if viewModel.mode == .post{
//                                viewModel.mode = .story
//                                viewModel.setToFixedAspectRatio = true
//                                viewModel.dictatedAspectRatio = 0.5625
//                                viewModel.choiceLimit = 1
//                                viewModel.resetframeProperties()
//                            } else{
//                                viewModel.mode = .post
//                                viewModel.setToFixedAspectRatio = false
//                                viewModel.choiceLimit = 10
//                                viewModel.resetframeProperties()
//
//                            }
//                        }, label: {
//                            Text(viewModel.mode == .post ? "STORY" : "POST")
//                                .padding()
//                                .foregroundColor(.white)
//                                .background(
//                                           Capsule()
//                                               .fill(Color.black.opacity(0.6))
//                                       )
//                                .padding(.trailing, 30)
//                                .padding(.bottom, 30)
//                        })
//                        
//                        
//                        ,alignment: .bottomTrailing
//                    )
        
                
            }
            
            
            .background(Color(.white))
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear{
            viewModel.setToFixedAspectRatio = true
            viewModel.dictatedAspectRatio = 1
            viewModel.resetframeProperties()
        }

        .onChange(of: showLimitedPicker) { oldValue, newValue in
            
            if oldValue == true && newValue == false{
                viewModel.fetchedAssets = []
                viewModel.selectedAssets = []
                viewModel.currentPage = 0
                viewModel.fetchImages()
                
                
            }
        }
        
        .alert(isPresented: $viewModel.permissionAlertVisible) {
            Alert (title: Text("Camera access required to take photos"),
                   message: Text("Go to Settings?"),
                   primaryButton: .default(Text("Settings"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }),
                   secondaryButton: .default(Text("Cancel")))
        }
        
    }
    
    
    var settingButton: some View{
        
        Button(action: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }, label: {
            Image(systemName: "gearshape")
                .foregroundColor(.black)
        })
    }
    
    var addMorePhotoButton: some View{
        
        Button(action: {
            showLimitedPicker = true
        }, label: {
            Image(systemName: "plus.square.on.square")
                .foregroundColor(.black)
            
            LimitedLibraryPicker(isPresented: $showLimitedPicker, viewModel: viewModel)
                .frame(width: 0, height: 0)
            
        })
    }
    
    var placeholderImage: some View{
        Image(systemName: "photo")
            .resizable()
            .foregroundColor(.black)
            .frame(width: 70, height:  70)
    }
    
    
    var dismissButton: some View{
        
        Button(action: {
            
            dismiss()
            
        }, label: {
            Image(systemName: "xmark")
                .foregroundColor(.black)
                .font(.system(size: 28, weight: .light))
            
        })
    }
    
    var albumMenu: some View {
        
        Menu {
            ForEach(viewModel.assetCollections, id: \.localIdentifier) { collection in
                Button(action: {
                    print("Selected folder: \(collection.localizedTitle ?? "Untitled")")
                    viewModel.selectedAssetCollection = collection
                    viewModel.fetchedAssets = []
                    viewModel.selectedAssets = []
                    viewModel.currentPage = 0
                    viewModel.fetchImages()
                }) {
                    Label(collection.localizedTitle ?? "Untitled", systemImage: "folder")

                }
            }
        } label: {
            Label("Albums", systemImage: "rectangle.stack")
                .foregroundColor(.black)
        }
    }
    
 
}










