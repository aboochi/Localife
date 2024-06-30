import SwiftUI

enum PrivacyLevel: String, CaseIterable, Identifiable {
    
    case publicAccess = "Public"
    case neighbors = "Neighbors"
    case privateAccess = "Private"


    var id: String { self.rawValue }
}

struct PrivacySettingsView: View {
    
    
    @EnvironmentObject var session : AuthenticationViewModel
    @EnvironmentObject var viewModel: ProfileViewModel

    var body: some View {
        Form {
            Section(header: Text("Privacy Settings")) {
                ForEach(PrivacyLevel.allCases) { level in
                    Button(action: {
                        session.userViewModel.dbUser?.privacyLevel = level.rawValue
                        Task{
                            try await viewModel.updatePrivacy(privacy: level)
                        }
                    }) {
                        HStack {
                            Text(level.rawValue)
                            Spacer()
                            
                            Image(systemName: session.dbUser.privacyLevel == level.rawValue ? "largecircle.fill.circle" : "circle")
                                .imageScale(.large)
                                .foregroundColor(session.dbUser.privacyLevel == level.rawValue ? .blue : .gray.opacity(0.7))
                                

                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            
            VStack(alignment: .leading, spacing: 10){
                Text("When you choose the Public access level, all users of the app can view your photos, listings, followers, followings, and any associated information.")
                    
                
                Text("Selecting the Neighbors access level restricts your information to only those within your defined neighborhood and your followers.")
                   
                
                Text("Selecting the Private access level ensures that your information remains accessible only to your followers.")
                   
            }
            .font(.system(size: 12, weight: .light))
            .foregroundColor(.gray)
        }
        .navigationTitle("Privacy")
    }
}

#Preview {
    PrivacySettingsView()
}
