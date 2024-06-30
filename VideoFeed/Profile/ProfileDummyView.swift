//
//  ProfileDummyView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/13/24.
//

import SwiftUI


struct Dummy: View {
    
    //@Environment(\.dismiss) var dismiss
    @EnvironmentObject var session : AuthenticationViewModel
    @StateObject var viewModel: ProfileViewModel
    @State var presentImagePicker = false
    @State var actionOrderFollowers: FollowActionOrder = .none
    @State var actionOrderFollowing: FollowActionOrder = .none
    @State var selectedId: String?
    @State  var showOptions: Bool = false
    @State var activeFollowerNav: Bool = false
    @State var activeFollowingNav: Bool = false

    @Binding var path: NavigationPath
    @ObservedObject  var homeIndex = HomeIndex.shared
    let spacing: CGFloat = 5
    @State  var selectedOption = "Posts"
    let options = ["Posts", "Listings"]
    
    @State var navigationType: ProfileNavigationType = .none
    @State var contentId: String = ""
    @State var navigationIndex: Int = 0
    let isPrimary: Bool

    
    
    
    var body: some View {
        
        VStack{
            
            
            if isPrimary{
                Button {
                    path.append(ProfileNavigationType.setting)
                } label: {
                    Text("Fuck you navigation")
                }
            }else{
                NavigationLink {
                    SettingView1()
                        .environmentObject(viewModel)
                        .environmentObject(session)
                } label: {
                    Text("Fuck you navigation")

                }

            }
            
          
            
        }
        .navigationDestination(for: ProfileNavigationType.self) { value in
           
            if value == .setting{
                SettingView1()
                    .environmentObject(viewModel)
                    .environmentObject(session)
            }
        
           // handleNavigation(value: value)
      
    }
       
    }
}
