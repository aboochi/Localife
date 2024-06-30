//
//  MessageAlbum.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/20/24.
//

import SwiftUI

struct MessageAlbum: View {
    let message: Message
    @Environment(\.dismiss) var dismiss
    @State var currentPage: Int = 0
    @State  var currentZoom = 1.0
    @State var anchorPoint: UnitPoint = .center
    
    var body: some View {
        
        ZStack{
            
            Color.black
                .ignoresSafeArea()
            
            VStack{
                HStack{
                    Button(action: {
                        dismiss()
                    }, label: {
                        
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .light))
                            .padding()
                            .frame(alignment: .leading)
                    })
                    Spacer()
                }
                
                Spacer()
                
                if let urls = message.urls, urls.count > 0, let aspectRatio = message.aspectRatio{
                    MediaSlideViewML(urls: urls, id: message.id, aspectRatio: aspectRatio, mediaCategory: .message, currentPage: $currentPage , playedPostIndex: .constant(0), postIndex: 0 ,  currentZoom: $currentZoom)
                        .scaleEffect(currentZoom , anchor: anchorPoint)
                        .zIndex(1)
                        .modifier(ZoomModifier(currentZoom: $currentZoom, anchorPoint: $anchorPoint))
                    
                    
                }
                
                Spacer()
                
                
                //            HStack{
                //
                //                Button(action: {
                //
                //
                //                }, label: {
                //
                //                    Image(systemName: "square.and.arrow.down")
                //                        .foregroundColor(.black)
                //                        .font(.system(size: 22, weight: .light))
                //                        .padding()
                //                        .frame(alignment: .leading)
                //                })
                //
                //                Button(action: {
                //                }, label: {
                //
                //                    Image(systemName: "arrowshape.turn.up.forward")
                //                        .foregroundColor(.black)
                //                        .font(.system(size: 22, weight: .light))
                //                        .padding()
                //                        .frame(alignment: .leading)
                //                })
                //
                //
                //            }
            }
        }
    }
}


