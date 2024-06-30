//
//  CreateListingView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 5/9/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import GeohashKit




enum ListingCategory: String, CaseIterable, Identifiable {
    case ride = "Ride"
    case sale = "Sale"
    case event = "Event"
    case pet = "Pet"
    case shopping = "Shopping"
    case sublease = "Sublease"
    case other = "Other"
    
    
    var id: String { self.rawValue }
}

enum PlaceType{
    case origin
    case destination
}

enum ListingFormTypeEnum{
    case create
    case edit
}

struct CreateListingView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel : CreateListingViewModel
    @EnvironmentObject var session: AuthenticationViewModel
    @Binding var showCreateListing: Bool
    @State  var selectedRange = "$"
    let titleCharacterLimit = 30
    let screenWith: CGFloat = UIScreen.main.bounds.width
    let options = ["$", "$$", "$$$"]
    let formType: ListingFormTypeEnum
    let listing: Listing?
    @State var goToPreviewPage: Bool = false

 
    var body: some View {
        
        NavigationStack{
            VStack{
                
                Form{
                    
                    Section("Necessary Information") {
                        
                        categoryPicker
                        titleField
                        mandatoryDatePickers
                        mandatoryPlacePicker
                        mandatoryPricePicker

                    }
                    
                    description
                    imagePicker
                    
                    Section("More Information (Optional)"){
                    
                        optionalDatePicker
                        optionalPricePicker
                        optionalPlacePicker
                        Toggle("Visible to Public", isOn: $viewModel.isPublic)
                        Toggle("Allow Direct Message", isOn: $viewModel.allowMessage)
   
                    }
                    
                }
            }
            .navigationTitle(formType == .create ? "New Listing" : "Edit Listing (\(viewModel.selectedCategory))")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: leadingBar, trailing: trailingBar)
            
        }
        
        .onChange(of: viewModel.activeNextButton, { oldValue, newValue in
            if newValue{
                switch formType {
                case .create:
                    goToPreviewPage = true
                case .edit:
                    
                    Task{
                        do{
                            try await viewModel.shareListing(formType: .edit, existingListing: listing)
                            showCreateListing = false

                        }catch{
                            
                            print("failed to edit the listing:   \(error.localizedDescription)")
                        }
                    }
                }
            }
        })
       
        
        .onAppear{
            
            if let listing = listing, formType == .edit{
                viewModel.selectedCategory = listing.category
               
                if let first = listing.originPlaceName, let second = listing.originPlaceAddress{
                    viewModel.originPlace = (first, second)
                }
                if let first = listing.destinationPlaceName, let second = listing.destinationPlaceAdress{
                    viewModel.destinationPlace = (first, second)
                }
               
                if let date = listing.desiredTime?.dateValue(){
                    viewModel.selectedDate = date
                }
                if let date = listing.endTime?.dateValue(){
                    viewModel.endDate = date
                }
                viewModel.selectedPrice = listing.price ?? 0
                viewModel.isPublic = listing.isPublic
                viewModel.allowMessage = listing.allowMessage
                viewModel.title = listing.title
                viewModel.description = listing.description ?? ""
                
                print("price: after setting  >>>>>>>>  \(viewModel.selectedPrice)")

            }
            updatePricerange()
        }
        
        .modifier(CreateListingModifier(viewModel: viewModel))
     
    }
    
}



extension CreateListingView{
    
    
    @ViewBuilder
    var categoryPicker: some View{
        
        
        if formType == .create{
            
            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(ListingCategory.allCases){ category in
                    Text(category.rawValue)
                }
            }
        }
    }
    
    
    @ViewBuilder
    var titleField: some View{
        
        TextField("Write a Title (up to 30 characters)", text: $viewModel.title)
            .onChange(of: viewModel.title) { _, newValue in
                if newValue.count > 0{
                    viewModel.showTitleError = false
                }
                if newValue.count > titleCharacterLimit {
                    viewModel.title = String(newValue.prefix(titleCharacterLimit))
                }
                    
            }
            .onAppear{
                viewModel.title = listing?.title ?? ""
            }
            .modifier(CreateListingErrorOverlay(showError: $viewModel.showTitleError))
    }
    
    @ViewBuilder
    var optionalPlacePicker: some View{
        
        
        if viewModel.selectedCategory == ListingCategory.sale.rawValue  || viewModel.selectedCategory == ListingCategory.other.rawValue || viewModel.selectedCategory == ListingCategory.pet.rawValue{
            
            ListingPlacePicker(viewModel: viewModel, placeType: .origin , listing: listing)
            
            
        }
    }
    
  
    
    
    @ViewBuilder
    var optionalDatePicker: some View{
        
        if viewModel.selectedCategory == ListingCategory.sale.rawValue || viewModel.selectedCategory == ListingCategory.other.rawValue {
            
            HStack{
                Text("Valid until")
                Spacer()
                DatePicker("", selection: $viewModel.expireDate, displayedComponents: .date)
                    .labelsHidden()
                
            }
        }

    }
    
    @ViewBuilder
    var imagePicker: some View{
        
        if formType == .create{

        
        var sectionTitle: String{
            if viewModel.selectedCategory == ListingCategory.sale.rawValue || viewModel.selectedCategory == ListingCategory.pet.rawValue || viewModel.selectedCategory == ListingCategory.sublease.rawValue{
                return ("(Necessary)")
            }else{
                return("(Optional)")
            }
        }
            if viewModel.selectedCategory != ListingCategory.ride.rawValue{
                Section("Image / Video \(sectionTitle)") {
                    
                    imageSection()
                        .modifier(CreateListingErrorOverlay(showError: $viewModel.showImageError))
                    
                    
                }
            }
        }
    }
    
    @ViewBuilder
    var description: some View{
        
        var sectionTitle: String{
            if viewModel.selectedCategory == ListingCategory.pet.rawValue || viewModel.selectedCategory == ListingCategory.other.rawValue || viewModel.selectedCategory == ListingCategory.shopping.rawValue{
                return ("(Necessary)")
            }else{
                return("(Recommended)")
            }
        }
        
        Section("Description \(sectionTitle)"){
            TextEditor(text: $viewModel.description)
            
                .frame(height: 100)
                .onAppear{
                    viewModel.description = listing?.description ?? ""
                }
            
               
                .modifier(CreateListingErrorOverlay(showError: $viewModel.showDescriptionError))
            
            
        }
    }
    
    
    
    @ViewBuilder
    var optionalPricePicker: some View{
        
        if viewModel.selectedCategory != ListingCategory.sale.rawValue && viewModel.selectedCategory != ListingCategory.sublease.rawValue && viewModel.selectedCategory != ListingCategory.other.rawValue {
            
            PricePicker(selectedPrice: $viewModel.selectedPrice, step: $viewModel.step, range: $viewModel.range, category: $viewModel.selectedCategory)
            


                .onAppear{
                    
                    viewModel.selectedPrice = listing?.price ?? 0
                }
          
        }
    }
    
    @ViewBuilder
    var mandatoryPricePicker: some View{
        
        if viewModel.selectedCategory == ListingCategory.sale.rawValue || viewModel.selectedCategory == ListingCategory.sublease.rawValue  {
            
            PricePicker(selectedPrice: $viewModel.selectedPrice, step: $viewModel.step, range: $viewModel.range, category: $viewModel.selectedCategory)
            
              
            
            if viewModel.selectedCategory == ListingCategory.sale.rawValue{
                priceRangePicker
            }
            
        }
    }
    
    
    @ViewBuilder
    var mandatoryPlacePicker: some View{
        
        if viewModel.selectedCategory == ListingCategory.ride.rawValue  || viewModel.selectedCategory == ListingCategory.shopping.rawValue ||
            viewModel.selectedCategory == ListingCategory.event.rawValue || viewModel.selectedCategory == ListingCategory.sublease.rawValue{
            
            ListingPlacePicker(viewModel: viewModel, placeType: .origin, listing: listing)
                .modifier(CreateListingErrorOverlay(showError: $viewModel.showOriginError))
            
            
            
            
            if viewModel.selectedCategory == ListingCategory.ride.rawValue  || viewModel.selectedCategory == ListingCategory.shopping.rawValue {
                
                ListingPlacePicker(viewModel: viewModel, placeType: .destination , listing: listing)
                    .modifier(CreateListingErrorOverlay(showError: $viewModel.showDestinationError))
                
                
            }
        }

    }
    
    
    @ViewBuilder
    var mandatoryDatePickers: some View{
        
        if viewModel.selectedCategory != ListingCategory.sale.rawValue && viewModel.selectedCategory != ListingCategory.pet.rawValue && viewModel.selectedCategory != ListingCategory.other.rawValue{
            
            HStack{
                Text((viewModel.selectedCategory == ListingCategory.event.rawValue || viewModel.selectedCategory == ListingCategory.sublease.rawValue) ? "Start" : "Date & Time")
                Spacer()
                DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .labelsHidden()
                if viewModel.selectedCategory != ListingCategory.sublease.rawValue {
                    DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
            
            if viewModel.selectedCategory == ListingCategory.event.rawValue || viewModel.selectedCategory == ListingCategory.sublease.rawValue{
                HStack{
                    Text("End")
                    Spacer()
                    DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
                        .labelsHidden()
                    if viewModel.selectedCategory == ListingCategory.event.rawValue {
                        DatePicker("", selection: $viewModel.endDate, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                }
                
                
            }
            
        }
    }
    
    
    @ViewBuilder
    func imageSection() -> some View{
        
        
        if let imagePickerViewModel = viewModel.imagePickerViewModel, viewModel.selectedAssets.count > 0{
            
            ZStack{
                ImagePickerSlidePreview(viewModel: imagePickerViewModel)
                    .frame(width: screenWith * 0.7, height: screenWith * 0.7)
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
        }
        
        VStack {
            
            Button(action: {
                if viewModel.imagePickerViewModel == nil{
                    viewModel.imagePickerViewModel = ImagePickerViewModel()
                }
                viewModel.showImagePicker = true
                
            }, label: {
                
                Label {
                    Text("Photos Library")
                } icon: {
                    Image(systemName: "photo.on.rectangle")
                }
            })
            
        }
        
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    
    @ViewBuilder
    var leadingBar: some View{
        
        Button(action: {
            viewModel.imagePickerViewModel = nil
            showCreateListing = false
            dismiss()
        }, label: {
            Image(systemName: "xmark")
            
        })
        
    }
    
    
    
    @ViewBuilder
    var trailingBar: some View{
        
        
        Button {
            
            
            switch viewModel.selectedCategory {
            case ListingCategory.ride.rawValue:
                let (result1, result2, result3) = (viewModel.validateOriginPlace(), viewModel.validateDestinationPlace(), viewModel.validateTitle())
                viewModel.activeNextButton = result1 && result2 && result3
                
            case ListingCategory.shopping.rawValue:
                let (result1, result2, result3, result4) = (viewModel.validateOriginPlace() , viewModel.validateDestinationPlace() , viewModel.validateTitle() , viewModel.validateDescription())
                viewModel.activeNextButton = result1 && result2 && result3 && result4
                
            case ListingCategory.sale.rawValue:
                var (result1, result2) = (viewModel.validateImages() , viewModel.validateTitle())
                if formType == .edit{ result1 = true}
                viewModel.activeNextButton = result1 && result2
                
            case ListingCategory.sublease.rawValue:
                var (result1, result2, result3) = (viewModel.validateImages() , viewModel.validateTitle() , viewModel.validateOriginPlace())
                if formType == .edit{ result1 = true}
                viewModel.activeNextButton = result1 && result2 && result3
                
            case ListingCategory.event.rawValue:
                let (result1, result2) = (viewModel.validateTitle() , viewModel.validateOriginPlace())
                viewModel.activeNextButton = result1 && result2
                
            case ListingCategory.pet.rawValue:
                var (result1, result2, result3) = (viewModel.validateTitle() , viewModel.validateDescription(),viewModel.validateImages() )
                if formType == .edit{ result3 = true}
                viewModel.activeNextButton = result1 && result2 && result3
                
            default:
                let (result1, result2) = (viewModel.validateTitle() , viewModel.validateDescription())
                viewModel.activeNextButton = result1 && result2
            }
            
            
            
        } label: {
            Text(formType == .create ?   "Next" : "Done")
        }
        .navigationDestination(isPresented: $goToPreviewPage) {
            
            
            ListingCoverCellPreview(viewModel: viewModel, showCreateListing: $showCreateListing)
                .environmentObject(session)
        }
        
    }
    
    
    @ViewBuilder
    var priceRangePicker: some View{
        
        Picker("", selection: $selectedRange) {
            ForEach(options, id: \.self) { option in
                Text(option)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: selectedRange) { oldValue, newValue in
            
            switch selectedRange {
            case "$":
                viewModel.selectedPrice = 50
                viewModel.step = 5
                viewModel.range = 5...200
                
            case "$$":
                viewModel.selectedPrice = 500
                viewModel.step = 50
                viewModel.range = 50...3000
                
            case "$$$":
                viewModel.selectedPrice = 5000
                viewModel.step = 200
                viewModel.range = 200...20000
                
            default:
                viewModel.selectedPrice = 50
                viewModel.step = 5
                viewModel.range = 5...200
                
            }
            
        }
    }
    
    
    
    func updatePricerange(){
        
        if  0 <= viewModel.selectedPrice && viewModel.selectedPrice <= 100{
            
            viewModel.step = 5
            viewModel.range = 5...200
            selectedRange = "$"
        }else if 100 < viewModel.selectedPrice && viewModel.selectedPrice <= 2000{
            viewModel.step = 50
            viewModel.range = 50...3000
            selectedRange = "$$"

            
        }else{
            viewModel.step = 200
            viewModel.range = 200...20000
            selectedRange = "$$$"

        }
        
        
    }
    
    
}


struct CreateListingErrorOverlay: ViewModifier{
    
    @Binding var showError: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group{
                    if showError{
                        Text("Empty")
                            .foregroundColor(.red)
                            .allowsHitTesting(false)
                            .padding(.horizontal, 5)
                    }
                }
                ,alignment: .trailing
            )
    }
}


