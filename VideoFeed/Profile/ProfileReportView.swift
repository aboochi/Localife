//
//  ProfileReportView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/9/24.
//

import SwiftUI

struct ProfileReportView: View {
    @Binding  var showOptions: Bool
    @State var reportText: String = ""
    @State var sendReport: Bool = false
    let contentId: String?
    let contentCategory : ContentCategoryEnum

    
    @EnvironmentObject var viewModel: ProfileViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    

    var body: some View {
        
        NavigationStack{
            
            ScrollView(showsIndicators: false){
                
                
                
                VStack(){
                    
                    Text("Report")
                        .font(.title2)
                    
                    Text("Please help us to make this community safer by your well intention reports. We will not share your identity with anyone unless it is an intellectual property case, in which we will reach out for more information.")
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    
                    VStack(alignment: .leading){
                        ForEach(ReportCategory.allCases, id: \.self) { category in
                            
                            
                            Divider()
                            NavigationLink {
                                
                                ReportCellView(reportCategory: category  , contentCategory: contentCategory, reportText: $reportText, sendReport: $sendReport, showOptions: $showOptions, contentId: contentId)
                                    .environmentObject(session)
                                    .environmentObject(viewModel)
                                
                            } label: {
                                
                                
                                HStack{
                                    Text(category.rawValue)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                            }
                            
                            
                            
                        }
                        
                    }
                }
                
            }
            .padding()
            
        }
        
       
        
    }
}

