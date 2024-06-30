//
//  ImagePickerLibraryGridView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/28/24.
//

import SwiftUI

struct ImagePickerLibraryGridView: View{
    @ObservedObject var viewModel: ImagePickerViewModel
    let spacing: CGFloat
    
    var body: some View{
        
        ScrollView(.vertical, showsIndicators: false){
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4), spacing: spacing) {
                ForEach($viewModel.fetchedAssets, id: \.id){ $assetItem in
                    
                    ImagePickerGridContentView(viewModel: viewModel, assetItem: $assetItem, numberOfColumns: 4, spacing: spacing)
                        .onAppear{
                            
                            
                            if assetItem.thumbnail == nil{
                                viewModel.loadthumbnail(assetItemBinding: $assetItem)
                            }
                            
                            viewModel.loadNextPage(assetItem: assetItem )
                        }
                    
                }
            }
            
        }
    }
}
