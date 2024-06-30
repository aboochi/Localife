//
//  ProfileImagePickerView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/28/24.
//

import SwiftUI
import PhotosUI

struct ProfileImagePickerView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @StateObject var viewModel = ImagePickerViewModel()
    let numberOfColumns: Int = 4
    let spacing: CGFloat = 6
    let deviceSize = UIScreen.main.bounds.size
    @State var showLimitedPicker = false
    @Environment(\.dismiss) var dismiss
    let scale: CGFloat =  0.8
    @Binding var selectedImage: UIImage?
    
   

    var body: some View {
        NavigationStack{
            VStack{
                HStack(alignment: .center){
                    
                    dismissButton
                    Spacer()
                    selectButton
                }
                .padding(.horizontal)
                
                imageGrid
                
                HStack{
                    
                    albumMenu
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
        .onAppear{
            viewModel.setToFixedAspectRatio = true
            viewModel.dictatedAspectRatio = 1
            viewModel.choiceLimit = 1
            viewModel.filter = .video
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
    
    
// MARK: UI ELEMENTS
    
    var imageGrid: some View{
        
        ZStack{
            Rectangle()
                .fill(.black)
                .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height / 2) * scale)
            
            if viewModel.selectedAssets.count == 0{
                placeholderImage
            }
   
            SelectedMediaDisplayView(viewModel: viewModel)
                .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height / 2) * scale)
                .scaleEffect(scale)

        }
        .frame(maxHeight: UIScreen.main.bounds.height / 2 )
    }
    
    
    var selectButton: some View{
        
        Button(action: {
            
            Task{
                if let assetItem = viewModel.selectedAssets.first, let image = viewModel.cropImage(assetItem: assetItem){
                    selectedImage = image
                    try await session.userViewModel.saveProfileImage(image: image)
                    print("photo is saved")
                }
            }
            
            dismiss()
            
        }, label: {
            
            Text("Select")
                .font(.headline)
                .foregroundColor(.blue.opacity(viewModel.selectedAssets.count < 1 ? 0.5 : 1))
        })
        .disabled(viewModel.selectedAssets.count < 1)
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
    
    
    
}










