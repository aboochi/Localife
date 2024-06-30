
import SwiftUI

struct SearchFieldView: View {
    @EnvironmentObject var viewModel: UserSearchViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @ObservedObject  var homeIndex = HomeIndex.shared
    @Binding var path: NavigationPath

    
    var body: some View {
        VStack {
            HStack {
                if homeIndex.isSearchExpanded {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                        .onTapGesture {
                            homeIndex.isSearchExpanded = false
                        }
                }
                
                TextField("Search for people...", text: $viewModel.searchString)
                    .padding(.horizontal)
                    .background(Color.white)
                    .frame(width: homeIndex.isSearchExpanded ? nil : 0, height: 35)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .animation(.spring(), value: homeIndex.isSearchExpanded)
                
                if !homeIndex.isSearchExpanded {
                    Spacer()
                }
            }
            .padding(.top, 60)
            .padding(.leading, 20)
            .padding(.trailing, 30)
           // .padding(.bottom, UIWindowScene.windows.first?.safeAreaInsets.bottom)
            .animation(.easeInOut(duration: 0.3), value: UIScreen.main.bounds.height)
            
            Spacer()
            
            ScrollView(showsIndicators: false){
                VStack(spacing: 10){
                    
                    if viewModel.searchString.count > 0{
                        userForEach(users: viewModel.usersSearch)
                    }else{
                        userForEach(users: viewModel.usersNeighbor)
                    }
         
                }
            }
            .onChange(of: viewModel.searchString) { oldValue, newValue in
                viewModel.searchString = viewModel.searchString.lowercased()
            }
            
            .onAppear{
                Task{
                    try await viewModel.fetchUsers(search: viewModel.searchString)
                    try await viewModel.fetchNeighborUsers()
                    try await viewModel.fetchUsersByTime()
                }
            }
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(1))
        .edgesIgnoringSafeArea(.all)
        
        .onChange(of: homeIndex.isSearchExpanded) { _, newValue in
            if !newValue{
                dismiss()
            }
        }
    
    }
    
    @ViewBuilder
    func userForEach(users: [DBUser]) -> some View {
        
        ForEach(users, id: \.id){ user in
            
            
            Button {
                let value = NavigationValuegeneral(type: .profile, user: user)
                path.append(value)
                 
            } label: {
                HStack(alignment: .center){
                    AvatarView(photoUrl: user.photoUrl, username: user.username, size: 40)
                    if let username = user.username{
                        VStack(alignment: .leading){
                            Text(username)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack{
                                if let firstName = user.firstName, let lastName = user.lastName{
                                    Text("\(firstName) \(lastName)")
                                }
                                else if let firstName = user.firstName{
                                    Text(firstName)
                                
                                }
                                else if let lastName = user.lastName{
                                    Text(lastName)
                                
                                }
                            }
                            .font(.system(size: 12, weight: .light))
                        }
                        .foregroundColor(.black)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
            }


         
            
        }
    }
}
