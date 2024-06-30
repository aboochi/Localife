//
//  SelectedImageView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/22/24.
//

import SwiftUI
import AVFoundation
import AVKit

struct SelectedMediaDisplayView: View {
    @ObservedObject var viewModel: ImagePickerViewModel
    @State var recreateID = false
    @State var currentOffset : CGSize = .zero
    @State var currentScale: CGFloat = 1
    @State var isDraging: Bool = false
    @State var isZooming: Bool = false


    var body: some View {
        ZStack{
            
            if let assetItem = viewModel.selectedAssets[safe: viewModel.displayIndex] {
                
                ZStack{
                    
                    if assetItem.asset.mediaType == .image{
                        
                        ImageDisplay(assetItem: assetItem)
                        
                    }else if assetItem.asset.mediaType == .video{
                        
                        
                        VideoDisplay(assetItem: assetItem)
         
                    }
                }

   
            }
    
        }
        .contentShape(Rectangle())
        .background(.black)
        .border(Color.white, width: 0.2)
        .clipped()
        .overlay {
            if isDraging || isZooming{
                ImageMesh()
            }
     
        }
    
    }
    
    @ViewBuilder
    func ImageDisplay(assetItem: AssetModel) -> some View{
        
        ZStack{
            
            if let image = assetItem.image{
                ZStack{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: viewModel.frameSize.width , height: viewModel.frameSize.height )
                        .scaleEffect(assetItem.scale * currentScale)

              
                }
                .offset(x: assetItem.offset.width + currentOffset.width, y: assetItem.offset.height + currentOffset.height)
                .dragGesture(currentOffset: $currentOffset, isDraging: $isDraging, assetItem: assetItem, viewModel: viewModel)
                .zoomGesture(currentScale: $currentScale, isZooming: $isZooming, assetItem: assetItem, viewModel: viewModel)

                
            } else{
                
                        ProgressView()
                            .onAppear{
                                
                                viewModel.loadImage(assetItem: assetItem)
         
                }
            }
        }
    }
    
    
    func VideoDisplay(assetItem: AssetModel) -> some View{
        
        ZStack{
            if var player = assetItem.player{
                
                ZStack{
                    ZStack(alignment: .center) {
                        
                        VideoPlayerWrapper(player: player, aspectRatio: viewModel.aspectRatioGeneral , isPlaying: .constant(true))
                        
                    }
                    
                    .scaleEffect(assetItem.initialScale * assetItem.scale * currentScale, anchor: .center)
                    .frame(width: viewModel.frameSize.width, height: viewModel.frameSize.height)
                    .frame(alignment: .center)
                }
                
                
                .modifier(videoPlayerModifier(viewModel: viewModel, player: player, recreateID: $recreateID))
                
                .offset(x: assetItem.offset.width + currentOffset.width, y: assetItem.offset.height + currentOffset.height)
                .dragGesture(currentOffset: $currentOffset, isDraging: $isDraging, assetItem: assetItem, viewModel: viewModel)
                .zoomGesture(currentScale: $currentScale, isZooming: $isZooming, assetItem: assetItem, viewModel: viewModel)
                
            } else{
                ProgressView()
                    .onAppear{
                        viewModel.loadVideo(assetItem: assetItem)
                    }
                
            }
        }
    }
  
}





struct DragModifier: ViewModifier {
    @Binding var currentOffset: CGSize
    @Binding var isDraging: Bool
    var assetItem: AssetModel
    var viewModel: ImagePickerViewModel

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDraging =  true
                        let translation = value.translation
                        currentOffset.width = translation.width
                        currentOffset.height = translation.height
                    }
                    .onEnded { _ in
                            isDraging =  false
                      
                        var accumulatedOffset: CGSize = assetItem.offset
                        accumulatedOffset.width += currentOffset.width
                        accumulatedOffset.height += currentOffset.height
                        currentOffset = .zero
                        viewModel.setOffset(id: assetItem.id, accumulatedOffset: accumulatedOffset)
                        viewModel.correctOffset(id: assetItem.id)
                        
                    }
            )
    }
}

struct ZoomGesture: ViewModifier{
    @Binding var currentScale: CGFloat
    @Binding var isZooming: Bool
    var assetItem: AssetModel
    var viewModel: ImagePickerViewModel
    
    func body(content: Content) -> some View{
        content
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = value
                        isZooming =  true

                    }
                    .onEnded { _ in

                            isZooming =  false

                        

                        if assetItem.scale * currentScale < 1.0 {
                            
                                viewModel.setAssetScale(id: assetItem.id, scale: 1.0)
                            
                        } else {
                            var scale = assetItem.scale
                            scale *= currentScale
                            viewModel.setAssetScale(id: assetItem.id, scale: scale)
                        }
                        currentScale = 1.0
                        viewModel.correctOffset(id: assetItem.id)
                    }
            )
        
    }
    
}

extension View {
    func dragGesture(currentOffset: Binding<CGSize>, isDraging: Binding<Bool>, assetItem: AssetModel, viewModel: ImagePickerViewModel) -> some View {
        self.modifier(DragModifier(currentOffset: currentOffset, isDraging: isDraging, assetItem: assetItem, viewModel: viewModel))
    }
}

extension View {
    func zoomGesture(currentScale: Binding<CGFloat>, isZooming: Binding<Bool>, assetItem: AssetModel, viewModel: ImagePickerViewModel) -> some View {
        self.modifier(ZoomGesture(currentScale: currentScale, isZooming: isZooming, assetItem: assetItem, viewModel: viewModel))
    }
}



extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


struct ImageMesh: View{
    
    var body: some View{
        ZStack{
            VStack {
                
                Spacer()
                Divider()
                    .overlay(.white.opacity(0.6))

                Spacer()
                Divider()
                    .overlay(.white.opacity(0.6))

                Spacer()
                
            }
      
            HStack {
                Spacer()
                Divider()
                    .overlay(.white.opacity(0.6))

                Spacer()
                Divider()
                    .overlay(.white.opacity(0.6))

                Spacer()
                
            }
            
        }
    }
}


struct videoPlayerModifier: ViewModifier {
    
    @ObservedObject var viewModel: ImagePickerViewModel
    var player: AVPlayer
    @Binding var recreateID: Bool
    
    func body(content: Content) -> some View{
        content
        
        .id(recreateID ? UUID() : nil) // Apply the id only if recreateID is true

        .onAppear{
            player.seek(to: .zero)
            player.play()
     
        }
        .onDisappear{
            player.seek(to: .zero)
            player.pause()
            
        }
        .onChange(of: viewModel.selectedAssets) { old, new in
            if old.count > new.count{
                
                recreateID = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    recreateID = false
                    player.play()
                }
            }
        }
        
        .onChange(of: viewModel.displayIndex) { old, new in
            
                
                recreateID = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    recreateID = false
                    player.play()
                }
            
        }
    }
    
    
    
}



