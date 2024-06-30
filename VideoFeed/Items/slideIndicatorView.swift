//
//  slideIndicatorView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/28/24.
//

import SwiftUI

struct slideIndicatorView:  View{

    @Binding var index: Int
    let numberOfSlides: Int
    let size: Int = 7
    var body: some View{
        
            
         
        HStack(spacing: 3){
                
                ForEach(0..<numberOfSlides, id: \.self){ num in
                    
                    Circle()
                        .foregroundColor(num == index ? .blue : .gray.opacity(getOpacity(num: num)))
                        .frame(width: getSize(num: num) , height: getSize(num: num))

                }
                
                
            }
        }
    
    func getSize(num: Int) -> CGFloat{
        if numberOfSlides > 5{
        let distance: Int = abs(num - index)
            return max(0.0, (CGFloat(size) - (CGFloat(size) * 0.1) * CGFloat(distance)*(distance>2 ? 2:1)))
        }else{
            return CGFloat(size)
        }
    }
    
    func getOpacity(num: Int) -> CGFloat{
       
            let distance: Int = abs(num - index)
            return (CGFloat(1) - (CGFloat(1) * 0.1) * CGFloat(distance)) * 0.5
        
    }
    
}



