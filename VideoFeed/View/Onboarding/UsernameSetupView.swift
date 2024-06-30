//
//  UsernameSetupView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/16/24.
//

import SwiftUI

struct UsernameSetupView: View {
    @EnvironmentObject var session: AuthenticationViewModel
    @StateObject var viewModel : UsernameViewModel
    @FocusState private var focus: FocusableField?
    @Binding var selection: Int 


    
    var body: some View {
        
        ZStack{
            if !viewModel.done{
                VStack{
                    if let firstName = session.dbUser.firstName{
                        Text("Welcome to Localife \(firstName)!")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .heavy))
                            .padding(15)
                    }
                    
                    Text("let's pick a username")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    
                    TextField("Username", text: $viewModel.username)
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Capsule().fill(Color.white.opacity(0.3)))
                        .overlay(
                            Capsule()
                                .stroke(.white, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focus, equals: .username)
                        .submitLabel(.go)
                        .onSubmit {
                            //self.focus = .password
                        }
                    
                  
                    Button(action: {
                        Task{
                            try await viewModel.setEnteredUsername()
                        }
                    }, label: {
                        Text("Choose")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Capsule().fill(Color.blue.opacity(0.5)))
                            .overlay(
                                Capsule()
                                    .stroke(.white, lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 5)

                    })
                    .disabled(viewModel.username == "")
                    
                    if viewModel.validity != .initial && viewModel.validity != .valid{
                        
                        Text("\(viewModel.validity.rawValue)")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                            .background(.white.opacity( viewModel.validity.rawValue.isEmpty ? 0.0 : 0.3))
                            .cornerRadius(10)
                            .frame(height: 60)
                    }
                    
                    
                    
                    
                }
                .onTapGesture {
                    focus = nil
                }
                
                .onChange(of: viewModel.username) { oldValue, newValue in
                    viewModel.username = viewModel.username.lowercased()
                    if viewModel.validity != .valid{
                        viewModel.validity = .initial
                    }
                }
                
            }else{
                
                Group{
                    Text("username: ")
                    
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                    
                    +
                    Text(viewModel.username)
                        .foregroundColor(.white)
                        .font(.system(size: 19, weight: .bold))
                }
                
            }
            
            
            
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
                session.userViewModel.dbUser?.username = viewModel.username
            }
        }
        
        .onChange(of: viewModel.validity) { oldValue, newValue in
            if newValue != .initial && newValue != .valid{
                
                HapticManager.shared.generateFeedback(of: .notification(type: .error))

            }else if newValue == .valid{
                
                Task{
                    try await viewModel.setEnteredUsername()

                }
            }
        }
    }
    
    
    
    func goNextStep(){
        var stage = session.onBoardingStage.rawValue
        if stage < 3{
            withAnimation(.easeInOut(duration: 0.5)){
                stage += 1
                let newStage = OnboaringStage(rawValue: stage)
                session.onBoardingStage = newStage ?? .done
            }
            Task{
                try await session.updateUserOnboardingState(onBoardingState:stage)
                HapticManager.shared.generateFeedback(of: .notification(type: .success))
                
            }
        }
    }

}


