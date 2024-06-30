//
//  uploadAllSteps.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/27/24.
//

import SwiftUI

struct UploadProgressBar:  View{
    
    let uploadAllSteps: CGFloat
    let uploadCompletedSteps: CGFloat
    var body: some View{
        Group{
           
                
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(uploadCompletedSteps != -1 ? Color.blue.opacity(0.2) : .white.opacity(0.01)) // Background color
                        .frame(width: UIScreen.main.bounds.width, height: 5)
                    
                    Rectangle()
                        .foregroundColor((uploadCompletedSteps / uploadAllSteps) == 1 ? Color.green : uploadCompletedSteps != -1 ? Color.blue : .white.opacity(0.01))
                        .frame(width: UIScreen.main.bounds.width * max(0, (uploadCompletedSteps / uploadAllSteps)), height: 5)
                    
                }
            
         
        }
    }
}

