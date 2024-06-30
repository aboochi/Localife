//
//  PostShareSlideDisplayView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/26/24.
//

import SwiftUI

struct PostShareSlideDisplayView: View {
  
    @ObservedObject var viewModel: ImagePickerViewModel
    let assetItem: AssetModel
    @State var recreateID = false
   
    @State var isDraging: Bool = false
    @State var isZooming: Bool = false
    @Binding var tabSelection: Int
    
    
    var body: some View {
        ZStack{
            
           
            if assetItem.assetIndex == tabSelection || assetItem.assetIndex == tabSelection+1 || assetItem.assetIndex == tabSelection-1{
                ZStack{
                    
                    if assetItem.asset.mediaType == .image{
                        
                        ImageDisplay(assetItem: assetItem )
                        
                    }else if assetItem.asset.mediaType == .video{
                        
                        
                        VideoDisplay(assetItem: assetItem)
                        
                    }
                }
                
                
            }
                
            
        }
        .contentShape(Rectangle())
        .border(Color.white, width: 0.2)
        .clipped()
        
        
     
        
    }
    
    
    
    @ViewBuilder
    func ImageDisplay(assetItem: AssetModel) -> some View{
        
        ZStack{
            
            if let image = assetItem.image{
                ZStack{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: viewModel.frameSize.width , height: viewModel.frameSize.height)
                        .scaleEffect(assetItem.scale)

                }
                .offset(x: assetItem.offset.width , y: assetItem.offset.height)

            } else{
                
                ProgressView()
                    .onAppear{
                        
                        viewModel.loadImage(assetItem: assetItem)
                        
                    }
            }
        }
    }
    
    
    @ViewBuilder
    func VideoDisplay(assetItem: AssetModel) -> some View{
        
        ZStack{
            if let player = assetItem.player{
                
                
                LazyVStack{
                    ZStack(alignment: .center) {
                        
                        VideoPlayerWrapper(player: player, aspectRatio: viewModel.aspectRatioGeneral, isPlaying: .constant(true))
                    }
  
                    .scaleEffect(assetItem.initialScale * assetItem.scale , anchor: .center)
                    .frame(width: viewModel.frameSize.width , height: viewModel.frameSize.height)
                    .frame(alignment: .center)
               
                }
           .modifier(videoPlayerModifier(viewModel: viewModel, player: player, recreateID: $recreateID))
                .offset(x: assetItem.offset.width , y: assetItem.offset.height )
                
                
            } else{
                ProgressView()
                    .onAppear{
                        viewModel.loadVideo(assetItem: assetItem)
                    }
                
            }
        }
    }
    
    
}
