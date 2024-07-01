//
//  CustomImagePicker.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/19/24.
//
import SwiftUI
import PhotosUI



struct PostImagePickerView: View {
    
    @EnvironmentObject var viewModel : ImagePickerViewModel
    let numberOfColumns: Int = 4
    let spacing: CGFloat = 6
    let deviceSize = UIScreen.main.bounds.size
    @State var showLimitedPicker = false
    @Binding var selection: Int
    let previousSelection: Int
    @Binding var showPostView: Bool
    @Environment(\.dismiss) var dismiss
    
    
    
   

    var body: some View {
        NavigationStack{
            VStack{
                HStack(alignment: .center){
                    
                    dismissButton
                    
                    Spacer()
                    
                    VStack{
                        SelectedMediaScrollView(viewModel: viewModel) { index in
                            OnTapGestureModifier {
                                viewModel.displayIndex = index
                            }
                        }
                    }
                    .frame(height: 37)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    NavigationLink {
                        
                        if viewModel.selectedAssets.count > 0 {
                            PostShareView(showPostView: $showPostView, selection: $selection)
                        }
                        
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
        
                }
                .padding(.horizontal)
                

                ZStack{
                    Rectangle()
                        .fill(.black)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                    
                    if viewModel.selectedAssets.count == 0{
                        placeholderImage
                    }
                    
           
                    SelectedMediaDisplayView(viewModel: viewModel)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                    
           
                }
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
                
                
                HStack{
                    
                    
                    albumMenu
                    
                    
                    Spacer()
                    aspectRatioResetButton
                    Spacer()

                    addMorePhotoButton
                    
                    settingButton
                    
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
                
                
                
                ImagePickerLibraryGridView(viewModel: viewModel, spacing: spacing)
                   
        
                
            }
            
            
            .background(Color(.black))
            .edgesIgnoringSafeArea(.bottom)
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
            Alert (title: Text("Gallery access required to share photos"),
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
                .foregroundColor(.white)
        })
    }
    
    var addMorePhotoButton: some View{
        
        Button(action: {
            showLimitedPicker = true
        }, label: {
            Image(systemName: "plus.square.on.square")
                .foregroundColor(.white)
            
            LimitedLibraryPicker(isPresented: $showLimitedPicker, viewModel: viewModel)
                .frame(width: 0, height: 0)
            
        })
    }
    
    var placeholderImage: some View{
        Image(systemName: "photo")
            .resizable()
            .foregroundColor(.white)
            .frame(width: 70, height:  70)
    }
    
    
    var dismissButton: some View{
        
        Button(action: {
            selection = previousSelection
            dismiss()
            
        }, label: {
            Image(systemName: "xmark")
                .foregroundColor(.white)
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
                .foregroundColor(.white)
        }
    }
    
    var aspectRatioResetButton: some View{
        
        Button(action: {
            viewModel.setToFixedAspectRatio.toggle()
            viewModel.resetframeProperties()
        }, label: {
            Image(systemName: "squareshape")
                .foregroundColor(viewModel.setToFixedAspectRatio ? .white : .blue)
        })
    }
 
    
}









