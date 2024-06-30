//
//  ImagesDisplayMessageCell.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/16/24.
//

import SwiftUI
import Kingfisher

enum NumberOfImages: Int{
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    
}

struct ImagesDisplayMessageCell: View {
    let images: [Any]
    let width : CGFloat
    let spacing: CGFloat  = 1.0
    let borderWidth : CGFloat = 0.0
    var numberOfImages : NumberOfImages{ return NumberOfImages(rawValue: images.count) ?? .zero}
    var body: some View {
        
        switch numberOfImages {
        case .zero:
            EmptyView()
        case .one:
            oneImages(images: images)
        case .two:
            twoImages(images: images)
        case .three:
            threeImages(images: images)
        case .four:
            fourImages(images: images)
        case .five:
            fiveImages(images: images)
        case .six:
            sixImages(images: images)
        case .seven:
            sevenImages(images: images)
        case .eight:
            eightImages(images: images)
        case .nine:
            nineImages(images: images)
        case .ten:
            tenImages(images: images)
        }
        
      
    }
    
  
    
    @ViewBuilder
    func largeSquare(item: Any) -> some View{
        if let url = item as? String{
            KFImage(URL(string: url))
                .resizable()
                .frame(width: (width - spacing )/2, height: (width - spacing )/2)
                .clipped()
                .border(Color(.white), width: borderWidth)
                .padding(0)
                .overlay(
                    Group{
                        if url.contains("messageVideo"){
                            Image(systemName: "video.fill")
                                .padding()
                        }
                    }
                    ,alignment: .bottomTrailing
                )
            
        } else if let uiImage = item as? UIImage {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: (width - spacing )/2, height: (width - spacing )/2)
                .clipped()
                .border(Color(.white), width: borderWidth)
                .padding(0)

          
        }
    }
    
    @ViewBuilder
        func mediumSquare(item: Any) -> some View{
            if let url = item as? String{
                KFImage(URL(string: url))
                    .resizable()
                    .frame(width: (width - 2*spacing )/3, height: (width - 2*spacing )/3)
                    .clipped()
                    .border(Color(.white), width: borderWidth)
                    .padding(0)

            } else if let uiImage = item as? UIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: (width - 2*spacing )/3, height: (width - 2*spacing )/3)
                    .clipped()
                    .border(Color(.white), width: borderWidth)
                    .padding(0)

            }
        }
    
    @ViewBuilder
            func smallSquare(item: Any) -> some View{
                if let url = item as? String{
                    KFImage(URL(string: url))
                        .resizable()
                        .frame(width: (width - 3*spacing )/4, height: (width - 3*spacing )/4)
                        .clipped()
                        .border(Color(.white), width: borderWidth)
                        .padding(0)

                } else if let uiImage = item as? UIImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: (width - 3*spacing )/4, height: (width - 3*spacing )/4)
                        .clipped()
                        .border(Color(.white), width: borderWidth)
                        .padding(0)

                }
            }
    
    @ViewBuilder
    func tenImages(images: [Any]) -> some View{
        
        VStack(spacing: spacing){
            HStack(spacing: spacing){
                smallSquare(item: images[5])
                smallSquare(item: images[4])
                smallSquare(item: images[3])
                smallSquare(item: images[2])
            }
            HStack(spacing: spacing){
                largeSquare(item: images[1])
                largeSquare(item: images[0])
            }
            HStack(spacing: spacing){
                smallSquare(item: images[9])
                smallSquare(item: images[8])
                smallSquare(item: images[7])
                smallSquare(item: images[6])
            }
        }
        .background(.white)
    }
    
    
    func nineImages(images: [Any]) -> some View{
        
        VStack(spacing: spacing){
            
            HStack(spacing: spacing){
                smallSquare(item: images[3])
                smallSquare(item: images[2])
                smallSquare(item: images[1])
            }
            HStack(spacing: spacing){
                VStack(spacing: spacing){
                    smallSquare(item: images[5])
                    smallSquare(item: images[4])
                }
                largeSquare(item: images[0])
            }
            HStack(spacing: spacing){
                smallSquare(item: images[8])
                smallSquare(item: images[7])
                smallSquare(item: images[6])
            }
        }
        .background(.white)
    }
    
    
    func eightImages(images: [Any]) -> some View{
        
        VStack(spacing: spacing){
            HStack(spacing: spacing){
                mediumSquare(item: images[4])
                mediumSquare(item: images[3])
                mediumSquare(item: images[2])
            }
            HStack(spacing: spacing){
                largeSquare(item: images[1])
                largeSquare(item: images[0])
            }
            HStack(spacing: spacing){
                mediumSquare(item: images[7])
                mediumSquare(item: images[6])
                mediumSquare(item: images[5])
            }
        }
        .background(.white)
    }
    
    func sevenImages(images: [Any]) -> some View{
        
        VStack(spacing: spacing){
            HStack(spacing: spacing){
                largeSquare(item: images[1])
                largeSquare(item: images[0])
            }
            HStack(spacing: spacing){
                HStack(spacing: spacing){
                    VStack(spacing: spacing){
                        smallSquare(item: images[4])
                        smallSquare(item: images[3])
                    }
                    VStack(spacing: spacing){
                        smallSquare(item: images[6])
                        smallSquare(item: images[5])
                    }
                }
                largeSquare(item: images[2])
            }
        }
        .background(.white)
    }
    
    func sixImages(images: [Any]) -> some View{
        
        HStack(spacing: spacing){
            VStack(spacing: spacing){
                smallSquare(item: images[3])
                smallSquare(item: images[2])
                smallSquare(item: images[1])
            }
            
            VStack(spacing: spacing){
                largeSquare(item: images[0])
                
                HStack(spacing: spacing){
                    smallSquare(item: images[5])
                    smallSquare(item: images[4])
                }
            }
        }
        .background(.white)
        
    }
    
    
    func fiveImages(images: [Any]) -> some View{
        VStack(spacing: spacing){
            HStack(spacing: spacing){
                largeSquare(item: images[1])
                largeSquare(item: images[0])
            }
            HStack(spacing: spacing){
                mediumSquare(item: images[4])
                mediumSquare(item: images[3])
                mediumSquare(item: images[2])
            }
        }
        .background(.white)
    }
    
    
    
    func fourImages(images: [Any]) -> some View{
        VStack(spacing: spacing){
            HStack(spacing: spacing){
                largeSquare(item: images[1])
                largeSquare(item: images[0])
            }
            HStack(spacing: spacing){
                largeSquare(item: images[3])
                largeSquare(item: images[2])
            }
        }
        .background(.white)
    }
    
    
    
    func threeImages(images: [Any]) -> some View{
        VStack(spacing: spacing){
            HStack(spacing: spacing){
                largeSquare(item: images[0])
                
            }
            HStack(spacing: spacing){
                smallSquare(item: images[2])
                smallSquare(item: images[1])
            }
        }
        .background(.white)
    }
    
    
    func twoImages(images: [Any]) -> some View{
       
            
            HStack(spacing: spacing){
                largeSquare(item: images[1])
                largeSquare(item: images[0])
            }
            .background(.white)
        
    }
    
    func oneImages(images: [Any]) -> some View{
       
            
            
                largeSquare(item: images[0])
            
        
    }
    
}


