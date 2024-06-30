//
//  AvatarView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/23/24.
//
import SwiftUI
import Kingfisher


struct AvatarView: View{
    let photoUrl: String?
    let username: String?
    let size: CGFloat
    
    init(photoUrl: String?, username: String?, size: CGFloat = 35) {
        self.photoUrl = photoUrl
        self.username = username
        self.size = size
    }
    var body: some View{
        ZStack{
            
            if let url = photoUrl, let urlObject = URL(string: url){
                
                KFImage(urlObject)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: size * 0.2, height: size * 0.2)))
                    .frame(width: size, height: size)
                
            } else if let username = username{
                
                Text(String(username.uppercased().prefix(1)))
                    .font(.system(size: size * 0.6, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: size, height: size)
                    .background(.gray.opacity(0.7))
                    .cornerRadius(size * 0.2)
                
                
            }else {
                Image(systemName: "person.crop.square.fill")
                    .resizable()
                    .foregroundColor(.gray.opacity(0.7))
                    .frame(width: size, height: size)
            }
        }
    }
}
