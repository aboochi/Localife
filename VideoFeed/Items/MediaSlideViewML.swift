//
//  MediaSlideViewML.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/18/24.
//

import SwiftUI

struct MediaSlideViewML: View {

    
    let urls: [String]
    let id: String
    let aspectRatio: CGFloat
    let mediaCategory: MediumCategory
    @Binding var currentPage: Int
    @Binding var playedPostIndex: Int
    let postIndex: Int
    @Binding  var currentZoom: Double

    
    let width = UIScreen.main.bounds.width
    
    var body: some View{
        
        ScrollViewReader{ proxy in
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                    
                        ZStack{
                            
                            if index == currentPage || index == currentPage + 1 || index == currentPage - 1{
                                MediaSingleSlideView(id: id, index: index, url: url, aspectRatio: aspectRatio, width: width, mediumCategory: mediaCategory , playedPostIndex: $playedPostIndex, postIndex: postIndex, slideIndex: index ,currentSlide: $currentPage )
                                
                            } else{
                                Rectangle()
                                    .foregroundColor(.white)
                                    .frame(width: width, height: width / max(aspectRatio, 0.65))
                            }
                            
                        }
                        .id(index)
                        
              
                        
                    
                }
                .frame(width: width, height: width / max(aspectRatio, 0.65))
                
            }
            .onChange(of: currentPage) { oldValue, newValue in
                withAnimation {
                    proxy.scrollTo(currentPage)
                }
            }
            
        }
        .scrollDisabled(true)
        .frame(width: UIScreen.main.bounds.width)
        .scrollTargetBehavior(.paging)
        .overlay(
            
            Group{
                HStack{
                    if currentPage > 0 && currentZoom == 1{
                        Button {
                            
                            currentPage -= 1
                            
                        } label: {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 16, weight: .regular))
                                .scaleEffect(2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(.gray.opacity(0.2)))
                                .shadow(radius: 5)
                            
                            
                        }

                    }
                    
                    Spacer()
                    if currentPage < urls.count - 1  && currentZoom == 1{
                        Button {
                            
                            currentPage += 1

                        } label: {
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 16, weight: .semibold))
                                .scaleEffect(2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(.gray.opacity(0.2)))
                                .shadow(radius: 5)
                            
                            
                        }

                    }
                }
                .padding()
            }
        
        )
        .overlay{
            VStack{
                Spacer()
                if  currentZoom == 1{
                    slideIndicatorView(index: $currentPage, numberOfSlides: urls.count)
                        .padding(.bottom, 7)
                }
                
            }
        }
        }
        
    }
}
