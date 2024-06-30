//
//  NotificationView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/30/24.
//

import SwiftUI



struct NotificationView: View {
    
    @EnvironmentObject var viewModel: NotificationViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding var path: NavigationPath
    
    

    var body: some View {
        
        ScrollView(showsIndicators: false){
            
            VStack{
                
                if viewModel.requestIds.count > 0{
                    
                
                    NavigationLink {
                        
                        FollowRequestsView()
                            .environmentObject(session)
                            .environmentObject(viewModel)

                        
                        
                    } label: {
                        
                        HStack{
                            let count = viewModel.requestIds.count
                            Text("\(count) \(count>1 ? "people are" : "person is") waiting for you")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                           
                            Spacer()
                            
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                            
                    }

                }

                
                ForEach(viewModel.notifications, id: \.id){ notification in
                    
                    NotificationCellView(notification: notification, viewModel: NotificationCellViewModel(notification: notification, currentUser: session.dbUser), path: $path)
                       // .environmentObject(NotificationCellViewModel(notification: notification, currentUser: session.dbUser))
                }
            }
        }
        .onAppear{
            Task{
                try await viewModel.getRequests()
            }
        }
    
        
    }
}



