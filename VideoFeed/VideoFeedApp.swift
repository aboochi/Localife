//
//  VideoFeedApp.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/6/24.
//

import SwiftUI
import FirebaseCore



@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      
       
            RootView()
            
        
      
      
    }
  }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      

    return true
  }
}
