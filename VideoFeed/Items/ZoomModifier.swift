//
//  ZoomModifier.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/3/24.

//



import SwiftUI

struct ZoomModifier1: ViewModifier{
    
    @Binding  var currentZoom: Double
    @Binding var anchorPoint: UnitPoint
    @State private var lastZoom: Double = 1.0
    @GestureState private var magnifyBy = 1.0

    
    func body(content: Content) -> some View {
        content
            .gesture(MagnificationGesture(minimumScaleDelta: 0)
                .onChanged({ value in
                    currentZoom = value
                })
                     
                    .onEnded({ value in
                        currentZoom = 1
                    })
            
            )
        
    }
}


import SwiftUI

struct ZoomModifier: ViewModifier{
    
    @Binding  var currentZoom: Double
    @Binding var anchorPoint: UnitPoint
    @State private var lastZoom: Double = 1.0
    @GestureState private var magnifyBy = 1.0

    
    func body(content: Content) -> some View {
        content
            .gesture(
                MagnifyGesture(minimumScaleDelta: 0)
                
                    .updating($magnifyBy) { value, gestureState, transaction in
                                    gestureState = value.magnification
                                }
                    .onChanged { value in
                        
                        if lastZoom == 1.0{
                            anchorPoint = value.startAnchor
                        }
                        if   value.magnification > 1 {
                                                    self.currentZoom = value.magnification
                                                    self.lastZoom = value.magnification
                                                }
                        
                    }
                    .onEnded { value in
                        withAnimation{
                            currentZoom = 1
                        }
                        
                        self.lastZoom = 1.0

                    }
            )
        
    }
}
