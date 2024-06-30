//
//  ImagePickerGridContentView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/28/24.
//

import SwiftUI

struct ImagePickerGridContentView: View{
    
    @ObservedObject var viewModel: ImagePickerViewModel
    @Binding var assetItem: AssetModel
    let deviceSize = UIScreen.main.bounds.size
    let numberOfColumns: Int
    let spacing: CGFloat
    var dimension: CGFloat {(deviceSize.width - (spacing * CGFloat(numberOfColumns - 1))) / CGFloat(numberOfColumns)}
    
    var body: some View{
        ZStack{
            ZStack{
                
                ThumbnailContent(assetItem: assetItem, dimension: CGSize(width: dimension, height: dimension)) { assetItem in
                    LayOverModifier(booleanValue: viewModel.selectedAssets.firstIndex(where: {$0.id == assetItem.id}) == nil)
                }
                
                if assetItem.asset.mediaType == .video{
                    showDuration(assetItem: assetItem)
                }
                
                
                if assetItem.asset.isFavorite{
                    favoriteItem
                }
                
                
                    selectionNumber(assetItem: assetItem)
                
                
            }
            .clipped()
            .onTapGesture {
                viewModel.addOrRemoveAsset(assetItem: assetItem)
            }
            
        }
        .frame(height: dimension)
        
    }
    
    
   

    var favoriteItem: some View {
        
        ZStack{
            Image(systemName: "heart.fill")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(5)
    }
    
    
    @ViewBuilder
    func selectionNumber(assetItem: AssetModel) -> some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(.black.opacity(0.1))
            
            Circle()
                .fill(.white.opacity(0.25))
            Circle()
                .stroke(.white, lineWidth: 1)
            
            if let index = viewModel.selectedAssets.firstIndex(where: {$0.id == assetItem.id}){
                
                Circle()
                    .fill(.blue)
                
                if viewModel.selectedAssets.count > 1{
                    Text("\(viewModel.selectedAssets[index].assetIndex + 1)")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }else{
                    Image(systemName: "checkmark")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: 20, height: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(5)
    }
    
    
    
    
    func showDuration(assetItem: AssetModel) -> some View{
        
        ZStack{
            if let duration = viewModel.getVideoDuration(for: assetItem.asset){
                Text("\(duration)")
                    .font(.caption) // Adjust the font size here
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(5)
    }
}

