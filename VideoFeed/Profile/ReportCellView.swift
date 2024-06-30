//
//  ReportCellView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/9/24.
//

import SwiftUI

struct ReportCellView: View {
    
    let reportCategory: ReportCategory
    let contentCategory: ContentCategoryEnum
    @Binding var reportText: String
    @Binding var sendReport: Bool
    @Binding var showOptions: Bool
    @FocusState var isFocused: Bool
    @EnvironmentObject var viewModel: ProfileViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    let contentId: String?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10){
            
            Text("Report: \(reportCategory.rawValue)")
                .font(.system(size: 18, weight: .semibold))
            
            Text(categoryDescription(category: reportCategory))
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(.systemGray))
            
            
          
          
                
                TextEditor( text: $reportText)
                    .focused($isFocused)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.primary.colorInvert())
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.black, lineWidth: 1 / 3)
                            .opacity(0.6)
                    )
                    .overlay(
                                  VStack(alignment: .leading){
                                      HStack {
                                          if reportText.isEmpty {
                                              Text("More information...")
                                                  .padding(.horizontal, 5)
                                                  .padding(.vertical, 10)
                                                  .foregroundColor(.gray)
                                          }
                                          Spacer()
                                      }
                                      .allowsHitTesting(false)
                                      Spacer()
                                  })
                
            if contentCategory != .user && contentCategory != .message{
                
                Button {
                    Task{
                        try await viewModel.sendReport(reportCategory: reportCategory, contentCategory: contentCategory, contentId: contentId, text: reportText)
                        reportText = ""
                        showOptions = false
                    }
                } label: {
                    Text("Report \(contentCategory.rawValue)")
                        .padding()
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            
            Button {
                Task{
                    try await viewModel.sendReport(reportCategory: reportCategory, contentCategory: .user, contentId: contentId, text: reportText)
                    reportText = ""
                    showOptions = false
                }
            } label: {
                Text("Report user")
                    .padding()
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }
            
            HStack{
                
                Spacer()
                Button {
                    showOptions = false
                } label: {
                   
                    Text("Cancel")
                        .padding(5)
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .regular))
                    
                   
                }
                
                Spacer()
            }
           

                
           Spacer()
        }
        .padding()
    }
    
    
    func categoryDescription(category: ReportCategory) -> String {
        
        switch category{
            
            
        case .inappropriate:
            return "This includes nudity, sexual activity, hate speech, violence, self-harm, or content related to drugs and eating disorders."
        case .harassment:
            return "This category covers any form of bullying or harassment."
        case .spam:
            return "This includes spammy content and any kind of fraudulent activities."
        case .misinformation:
            return "This is for content that spreads false information."
        case .intellectualProperty:
            return "This category covers violations of intellectual property rights."
        case .illegal:
            return "This includes the sale of illegal or regulated goods."
        case .other:
            return "You can report content for any reasons other than the listed options, including personal dislike of the content. Please leave us a note in the field below:"
        }
    }
    
}





