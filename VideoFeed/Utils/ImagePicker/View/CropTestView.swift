//
//  CropTestView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/26/24.
//

import SwiftUI
import AVFoundation

struct CropTestView: View {
    
    @ObservedObject var viewModel: ImagePickerViewModel
    var body: some View {
        
        
        ScrollView{
            VStack{
                ForEach($viewModel.selectedAssets, id: \.id){ $assetItem in
                    
                    if assetItem.asset.mediaType == .image{
                        if let image = viewModel.cropImage(assetItem: assetItem){
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .onAppear{
                                    print(" cropped image size: \(image.size)")
                                    print(" original image size: width: \(assetItem.asset.pixelWidth)  height: \(assetItem.asset.pixelHeight)")

                                }
                        }
                        
                    }  else if assetItem.asset.mediaType == .video {
                        if let url = assetItem.croppedVideoUrl{
                           let player = AVPlayer(url: url)
                            
                            VideoPlayerWrapper(player: player, aspectRatio: viewModel.aspectRatioGeneral , isPlaying: .constant(true))
                            
                                .frame(width: viewModel.frameSize.width, height: viewModel.frameSize.height)

                                .onAppear {
                                    player.play()
                                }
                        
                    } else {
                            
                            ProgressView()
                                .onAppear{
                                    
                                    
                                    Task{
                                         assetItem.croppedVideoUrl = try await viewModel.cropVideoAsset(assetItem: assetItem)
                                        
                                        print("print job completed")

                                    }
                                        
                                  
                                    
                                    
                                }
                        }
                    }
                    
                }
            }
        }
    }
}


