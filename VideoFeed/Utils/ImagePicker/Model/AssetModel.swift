//
//  AssetModel.swift
//  Localife
//
//  Created by Abouzar Moradian on 7/1/24.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct AssetModel: Identifiable, Equatable{
    var id: String = UUID().uuidString
    var asset: PHAsset
    var thumbnail: UIImage?
    var assetIndex: Int = -1
    var offset: CGSize = .zero
    var finalScale: CGFloat = 1
    var aspectRatio: CGFloat?
    var image: UIImage?
    var player: AVPlayer?
    var initialScale: CGFloat = 1
    var scale: CGFloat = 1
    var croppedVideoUrl: URL?

    
   
    mutating func setIntialScale(aspectRatioGeneral: CGFloat) {
        if aspectRatio == nil {
            setAspectRatio()
        }
        guard let aspectRatio = aspectRatio else { return }
        initialScale = max((aspectRatioGeneral / aspectRatio), (aspectRatio / aspectRatioGeneral))
    }

    
    mutating func setAspectRatio(){
        aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }
    
    func getAspectRatio() -> CGFloat{
        return CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }
    
    mutating func setOffset(_ value: CGSize){
        offset = value
    }

    
}
