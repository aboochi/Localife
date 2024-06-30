//
//  ListingInterestedView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/12/24.
//



class CategoryColorProvider {
    static func getColor(for category: String) -> String {
        switch category {
        case "Ride":
            return "#fcf5b5"
        case "Sale":
            return "#ffe4ed"
        case  "Event":
            return "#bbdff6"
        case "Pet", "Pet Assistance":
            return "#dddddd"
        case "Shopping":
            return "#acf2e4"
        case "Sublease":
            return "#fcba9a"
        default:
            return "#edf2f1"
        }
    }
}





class CategoryIconProvider {
    static func getSystemName(for category: String) -> String {
        switch category {
        case "Ride":
            return "car"
        case "Sale":
            return "tag"
        case  "Event":
            return "party.popper"
        case "Pet", "Pet Assistance":
            return "dog"
        case "Shopping":
            return "cart"
        case "Sublease":
            return "house"
        default:
            return "questionmark.circle"
        }
    }
}


import SwiftUI

struct ListingInterestedView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var viewModel: ListingViewModel
    @Binding var path: NavigationPath
    var favoriteDone : Bool { return  session.dbUser.listingCategory.count > 0 }
    @State var showCategorySelection: Bool = false

    
    var body: some View {
        
        VStack{
            
           
            if !favoriteDone{
                categoryIntroduction()
            }
           
            if viewModel.favoriteCategories.count > 0{
                
                HStack(spacing: 3){
                    Text(createCategoryListString())
                        .padding()
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#edf2f1"))
                        .cornerRadius(10.0)

            
                }
                .padding()

            }
            
            ListingLazyScrollView(userId: "", listingType: .interest, path: $path)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: leadingButton, trailing: trailingButton)
        .onAppear{
            Task{
                try await viewModel.fetchUserInterestListing()
            }

        }
        
        .sheet(isPresented: $showCategorySelection) {
            ListingCategorySelectionView()
                .presentationDetents([.medium])
        }
        

    }
    
   
    func createCategoryListString() -> String {
        
        var favoriteCategoriesString = "Your favorite categories:"

        for category in viewModel.favoriteCategories {
            favoriteCategoriesString += " \(category),"
        }

        favoriteCategoriesString.removeLast()
        return favoriteCategoriesString
    }
    
    
    
    @ViewBuilder
    func categoryName(name: String, hexColor: String) -> some View{
        
        Button(action: {
            if viewModel.favoriteCategories.contains(name){
                
                Task{
                    do{
                        viewModel.favoriteCategories.removeAll { $0 == name }
                        viewModel.listingInterest = []
                        viewModel.lastDocumentInterest = nil
                        try await viewModel.removeFavoriteCategory(category: name)
                        try await viewModel.fetchUserInterestListing()
                        
                    }
                }
                
             

            }else{
                
                Task{
                    do{
                        viewModel.favoriteCategories.append(name)
                        viewModel.listingInterest = []
                        viewModel.lastDocumentInterest = nil
                        try await viewModel.addFavoriteCategory(category: name)
                        try await viewModel.fetchUserInterestListing()
                        
                    }
                }
            }
            
    
            
        }, label: {
            
            Text(name)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .font(.subheadline)
                .foregroundColor(.black)
                .background(Color(hex: hexColor))
                .cornerRadius(20)
                .padding(5)
                .shadow(color: viewModel.favoriteCategories.contains(name) ? .black : .white, radius: 5)
        })
        
         
    }
    
    @ViewBuilder
    func categoryIntroduction() -> some View{
        
        VStack{
            Text("Select your preferred categories for notifications on new releases")
                .padding()
                .font(.system(size: 16, weight: .semibold))
                .background(Color(hex: "#efd9d1"))
                .cornerRadius(10.0)
                .padding()
                .multilineTextAlignment(.center)
            
            HStack{
                categoryName(name: "Ride", hexColor: CategoryColorProvider.getColor(for: "Ride"))
                categoryName(name: "Pet", hexColor: CategoryColorProvider.getColor(for: "Pet"))
                categoryName(name: "Sale", hexColor: CategoryColorProvider.getColor(for: "Sale"))
            }
            
            HStack{
                categoryName(name: "Event", hexColor: CategoryColorProvider.getColor(for: "Event"))
                categoryName(name: "Sublease", hexColor: CategoryColorProvider.getColor(for: "Sublease"))
                categoryName(name: "Shopping",hexColor: CategoryColorProvider.getColor(for: "Shopping"))
            }
        }
    }
    
    @ViewBuilder
    var leadingButton: some View{
        
        Button {
            session.userViewModel.dbUser?.listingCategory = viewModel.favoriteCategories
            if path.count > 0 {
                path.removeLast()
            }
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .semibold))
        }
    
    }
    
    
    
    @ViewBuilder
    var trailingButton: some View{
        
        Button {
            
            showCategorySelection = true
            
        } label: {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .semibold))
        }
    
    }
    
}


struct ListingCategorySelectionView: View {
    
    @EnvironmentObject var viewModel: ListingViewModel

    var body: some View {
        
        VStack(spacing: 10){
            ForEach(ListingCategory.allCases) { category in
                
                if category != .other{
                    HStack{
                        
                        Image(systemName: CategoryIconProvider.getSystemName(for: category.rawValue))
                        Text(category.rawValue)
                        
                        Spacer()
                        
                        
                        Button {
                            
                    
                            if viewModel.favoriteCategories.contains(category.rawValue){
                                
                                Task{
                                    do{
                                        
                                        
                                        
                                        viewModel.favoriteCategories.removeAll { $0 == category.rawValue }
                                        try await viewModel.removeFavoriteCategory(category: category.rawValue)
                                        viewModel.listingInterest = []
                                        viewModel.lastDocumentInterest = nil
                                        try await viewModel.fetchUserInterestListing()
                                        

                                        
                                    }
                                }
                                
                            }else{
                                
                                Task{
                                    do{
                                        viewModel.favoriteCategories.append(category.rawValue)
                                        try await viewModel.addFavoriteCategory(category: category.rawValue)
                                        viewModel.listingInterest = []
                                        viewModel.lastDocumentInterest = nil
                                        try await viewModel.fetchUserInterestListing()

                                        
                                    }
                                }
                                
                                
                            }
                            
                        } label: {
                            
                            Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(viewModel.favoriteCategories.contains(category.rawValue) ? .blue : .white)
                                .scaleEffect(2)
                                .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                                    .scaleEffect(2)
                            )
                        }

                     
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        CustomCorners(radius: 25, corners: [.bottomLeft, .topLeft, .bottomRight, .topRight])
                            .stroke(Color.black, lineWidth: 1)
                    )
                    
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    
}



