//
//  SelectedIMediaScrollView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/24/24.
//

import SwiftUI

struct SelectedMediaScrollView<ModifierType>: View where ModifierType: ViewModifier {
    @ObservedObject var viewModel: ImagePickerViewModel
    let dimension: CGSize = CGSize(width: 37, height: 37)
    let onTapAction: ((Int) -> ModifierType)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element.id) { index, assetItem in
                    ZStack {
                        ThumbnailContent(assetItem: assetItem, dimension: dimension, layOverModifier: { _ in
                            EmptyModifier()
                        })
                            .onAppear {
                                if assetItem.thumbnail == nil {
                                    viewModel.loadthumbnail(assetItem: assetItem)
                                }
                                
                                if assetItem.image == nil{
                                    viewModel.loadImage(assetItem: assetItem)
                                }
                                
                                if assetItem.asset.mediaType == .video && assetItem.player == nil{
                                    
                                        viewModel.loadVideo(assetItem: assetItem)
                                    
                                }
                            }
                           
                    }
                    .border(viewModel.displayIndex == index ? Color.yellow : Color.clear , width: 1)
                    .cornerRadius(2)
                    .modifier(onTapAction(index))
                }
            }
        }
    }
}

struct ThumbnailContent<ModifierType>: View where ModifierType: ViewModifier{
    var assetItem: AssetModel
    let dimension: CGSize
    let layOverModifier: ((AssetModel) -> ModifierType)

    var body: some View {
        ZStack{
            if let thumbnail = assetItem.thumbnail{
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: dimension.width , height: dimension.height)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .modifier(layOverModifier(assetItem))
                    
            } else{
                ProgressView()
                    .frame(width: dimension.width, height: dimension.height, alignment: .center)
                
                
            }
        }
    }
    
}





struct OnTapGestureModifier: ViewModifier {
    let onTapAction: () -> Void

    func body(content: Content) -> some View {
        content.onTapGesture {
            onTapAction()
        }
    }
}



struct LongTapGestureModifier: ViewModifier {
    let onTapAction: () -> Void

    func body(content: Content) -> some View {
        content
            .onLongPressGesture {
            onTapAction()
        }
 
    }
}


struct LayOverModifier: ViewModifier {
    let booleanValue:  Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Color.white.opacity(booleanValue ? 0: 0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                )
 
    }
}


struct CustomEmptyModifier: ViewModifier {
   

    func body(content: Content) -> some View {
        content
            .modifier(EmptyModifier())
 
    }
}
