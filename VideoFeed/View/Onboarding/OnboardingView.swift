import SwiftUI

struct OnboardingView: View {
    
    @State var selection: Int = 0
    @EnvironmentObject var session: AuthenticationViewModel
    let transition: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    
    var body: some View {
        
        
        switch session.onBoardingStage{
        case .done:
            HomeView(viewModel: HomeViewModel(user: session.dbUser))
            
        default:
            
            ZStack{
                VStack{
                    
                    RadialGradient(
                        gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)), Color(#colorLiteral(red: 0.3958167851, green: 0.5488277888, blue: 0.5647059083, alpha: 1))]),
                        center: .topLeading,
                        startRadius: 5,
                        endRadius: UIScreen.main.bounds.height)
                    
                }
                .ignoresSafeArea()
                
                VStack{
                    HStack{
                        Spacer()
                        Button(action: {session.onBoardingStage = .done}, label: {
                            Text("Skip all")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(.white)
                               
                               
                      
                        })
                        .padding()
                    }
                    Spacer()
                    HStack{
                        
                        progressCircles
                        
                        Spacer()
                        
                        
                        Button {
                            goNextStep()
                            
                        } label: {
                            Image(systemName: "arrow.forward")
                                .foregroundColor(.white)
                                .font(.system(size: 35, weight: .bold))
                                .padding([.bottom, .trailing], 40)
                            
                        }
                        
                    }
                    
                }

                
                tabView
            }
        }
    }
}



extension OnboardingView {
    
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
    
    
    
    private var tabView : some View {
        ForEach([session.onBoardingStage], id: \.self) { stage in
            switch stage.rawValue {
            case 0:
                UsernameSetupView(viewModel: UsernameViewModel(user: session.dbUser), selection: $selection)
                    .transition(transition)
            case 1:
                AvatarSetupView( selection: $selection)
                    .transition(transition)
            case 2:
                LocationSetupView(viewModel: LocationSetupViewModel(user: session.dbUser) , selection: $selection)
                    .transition(transition)
            default:
                SettingView()
                    .transition(transition)
            }
        }
    }
}



extension OnboardingView {
    
    private var progressCircles: some View{
        
        HStack{
            Circle()
                .foregroundColor( .white.opacity(session.onBoardingStage.rawValue != 0 ? 0.5 : 1) )
                .frame(width: session.onBoardingStage.rawValue != 0 ? 15 : 20, height: session.onBoardingStage.rawValue != 0 ? 15 : 20)
                .padding(.bottom, 40)
                .padding(.leading, 40)
            
            Circle()
                .foregroundColor( .white.opacity(session.onBoardingStage.rawValue != 1 ? 0.5 : 1) )
                .frame(width: session.onBoardingStage.rawValue != 1 ? 15 : 20, height: session.onBoardingStage.rawValue != 1 ? 15 : 20)
                .padding(.bottom, 40)
            
            Circle()
                .foregroundColor( .white.opacity(session.onBoardingStage.rawValue != 2 ? 0.5 : 1) )
                .frame(width: session.onBoardingStage.rawValue != 2 ? 15 : 20, height: session.onBoardingStage.rawValue != 2 ? 15 : 20)
                .padding(.bottom, 40)
        }
    }
}




