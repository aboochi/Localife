//
//  Setting.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/14/24.
//




import SwiftUI


struct SettingView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    var body: some View {
        List{
            Button(action: {
                
                Task{
                    do{
                        try session.signOut()
                    } catch{
                        print(error)
                    }
                }
                
            }, label: {
                Text("Sing Out")
            })
            
            if session.authProviders.contains(.email){
                emailSection
            }
            
            if session.authUser?.isAnonymous == true {
                anonymousSection
            }
            
            
        }
        .onAppear{
        
        }
        
        
        
        
        
    }
}

#Preview {
    SettingView()
}
extension SettingView{
    private var anonymousSection: some View{
        
        Section{
            Button(action: {
                Task{
                    do{
                        try await session.linkGoogle()
                        print("changing password")
                    } catch{
                        print(error)
                    }
                }
                
            }, label: {
                Text("Link Google Account")
            })
            
            
            
            Button(action: {
                Task{
                    do{
                        try await session.linkApple()
                        print("Update password")
                    } catch{
                        print(error)
                    }
                }
                
            }, label: {
                Text("Link Apple Account")
            })
            
            
            
            Button(action: {
                Task{
                    do{
                        try await session.linkEmail(email: "", password: "")
                        print("Update email")
                    } catch{
                        print(error)
                    }
                }
                
            }, label: {
                Text("Link With Email/Password")
            })
            
            
        } header: {
            Text("Link With Email/Password")
        }
        
    }
}



extension SettingView{
    private var emailSection: some View{
        
        Section{
            Button(action: {
                Task{
                    do{
                        try await session.resetPassword()
                        print("changing password")
                    } catch{
                        print(error)
                    }
                }
                
            }, label: {
                Text("Reset password")
            })
            
            
            
            Button(action: {
                Task{
                    do{
                       // try await session.updatePassword()
                        print("Update password")
                    } catch{
                        print(error)
                    }
                }
                
            }, label: {
                Text("Update password")
            })
            
            
            
            Button(action: {
                Task{
                    do{
                        //try await session.updateEmail()
                        print("Update email")
                    } catch{
                        print(error)
                    }
                }
                
            }, label: {
                Text("Update email")
            })
            
            
        } header: {
            Text("Email functions")
        }
        
    }
}
