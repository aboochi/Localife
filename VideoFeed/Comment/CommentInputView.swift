//
//  CommentInputView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/3/24.
//

import SwiftUI

struct CommentInputView: View {
    
    @Binding var inputText: String
    let placeholder: String = "Comment..."
    
    var action: () -> Void
    
    var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(Color(.separator))
                .frame(width: UIScreen.main.bounds.width, height: 0.8)
            
            HStack {
                TextField(placeholder, text: $inputText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(minHeight: 30)
                
                
                Button {
                    print("fuck")
                    //action()
                    
                } label: {
                    Text("Send")
                        .bold()
                        .foregroundColor(.black)
                }

                
//                Button(action:
//                        action
//                       
//                ) {
//                    Text("Send")
//                        .bold()
//                        .foregroundColor(.black)
//                }
            }.padding(.horizontal)
            
        }.padding(.bottom, 8)
    }
}

