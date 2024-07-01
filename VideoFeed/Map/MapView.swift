//
//  MapView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/25/24.
//

import SwiftUI
@_spi(Experimental) import MapboxMaps
import CoreLocation
import FirebaseFirestore
import Turf
import MapKit


enum MapNavigationType{
    case profile
    case listing
}

struct MapNavigationValue: Hashable{
    var type: MapNavigationType
    var id: String
    var user: DBUser
    
}


struct MapView: View {
    
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var listingViewModel: ListingViewModel
    @EnvironmentObject var viewModel: MapViewModel
    let london = CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474)
    @Environment(\.colorScheme) var colorScheme
    @State var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474), zoom: 11, bearing: 0, pitch: 0)
    @State private var allowOverlap: Bool = false
    @State var selected : String?
    @State var zoom: Double = 0
    @State var isVisible : [String: Bool] = [:]
    @State var showUserPreview: Bool = false
    let screenWidth = UIScreen.main.bounds.width
    @Binding var path: NavigationPath
    @State var userSavedLocation = CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474)
    
   
    var body: some View {
        
       
        ZStack{
         
      
            Map (viewport: $viewport) {
                
//                Puck2D(bearing: .heading)
//                        .showsAccuracyRing(true)
               
                ForEvery(viewModel.users) { user in
                    
                    if let geoPoint = user.location {
                        
                        let coordinate = convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
                        MapViewAnnotation(coordinate: coordinate) {
                            
                            Group{
                                if viewModel.showAnnotation{
                                    AvatarView(photoUrl: user.photoUrl, username: user.username, size: 30)
                                        
                                    
                                     
                                }else if user.id == session.dbUser.id{
                                    
                                 
                                        
                                        AvatarView(photoUrl: user.photoUrl, username: user.username, size: 30)
                                            .padding(1)
                                            .background(.white)
                                            .cornerRadius(6)
                                            .padding(1)
                                            .background(.black)
                                            .cornerRadius(7)
                                    
                                        .overlay (
                                            
                                            Group{
                                                if let listingId = user.listingIds.last, let listingTime = user.listingsTimes.last, listingTime.dateValue() > Date(){
                                                    Image(systemName: "tag.fill")
                                                        .foregroundColor(.blue)
                                                        .offset(x: 10, y: -10)
                                               }
                                            }
                                            ,alignment: .topTrailing
                                        )
                                    
                                        
                                }
                            }
                            .scaleEffect(selected == user.id ? 1.8 : 1)
                            .padding(selected == user.id ? 20 : 10)
                            .animation(.spring(), value: selected == user.id)
                            .onTapGesture {
                                
                                viewModel.selectedUser = user
                                showUserPreview = true
                               
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
                                    selected = user.id
                                    
                               }
                                
                               
                            }
                            .onAppear{
                                isVisible[user.id] = true
                            }
                           
                      
                        }
                        .allowOverlap(true)
                        .onVisibilityChanged(action: { visible in
                            isVisible[user.id] = visible
                            print("user: \(user.username)")
                        })
                        .selected(selected == user.id)
                        
                    

                    }
                            }
              

                
            }
            .onCameraChanged {
                        viewModel.setZoom($0.cameraState.zoom)
                //print("zoom: \($0.cameraState.zoom)")

                    }
                    
            
            .mapStyle(.light)
            .ignoresSafeArea(edges: .top)
            
            .onAppear{
                if let geoPoint = session.dbUser.location {
                    let coordinate = convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
                    userSavedLocation = coordinate
                    viewport = .camera(center: coordinate, zoom: 11, bearing: 0, pitch: 0)
                }
                     
            }
            
            .onChange(of: viewport.camera?.center, { oldValue, newValue in
                print("camera changed >>>>>>>>")
            })
            
         
            .overlay(
                
                Button(action: {
                    withViewportAnimation(.easeIn(duration: 1)) {
                        viewport = .followPuck(zoom: 14, pitch: 0)
                    }
                }, label: {
                    Image(systemName: "location.fill")
                        .scaleEffect(1.3)
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                        .padding()
                    
                    
                    
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(radius: 5)
                        )
                })
                
               
                .padding()
                .padding(.bottom, 20)
                ,alignment: .bottomTrailing
            )
            
            
            .overlay(
                
                Button(action: {
                    withViewportAnimation(.easeIn(duration: 1)) {
                        viewport = .camera(center: userSavedLocation, zoom: 11, bearing: 0, pitch: 0)

                    }
                }, label: {
                    Image(systemName: "location.north.fill")
                        .scaleEffect(1.3)
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(radius: 5)
                        )
                })
                
               
                .padding()
                .padding(.bottom, 20)
                ,alignment: .bottomLeading
            )
            
            
     
            
            
            if showUserPreview{
                Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selected = nil
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                                        if selected == nil{
                                            showUserPreview = false
                                            viewModel.selectedUser = nil
                                        }
                                    }
                                }
            }
            
            
            VStack(spacing: 10){
                
                if !viewModel.showAnnotation{
                    VStack{
                    ScrollView(.horizontal, showsIndicators: false){
                       
                            HStack{
                                ForEach(viewModel.users, id: \.id){ user in
                                    
                                    
                                    
                                    if let visibile = isVisible[user.id], visibile == true, let geoPoint = user.location{
                                        
                                        let coordinate = convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
                                        
                                        AvatarView(photoUrl: user.photoUrl, username: user.username, size: 50)
                                            .scaleEffect(selected == user.id ? 1.2 : 1)
                                            .animation(.spring(), value: selected == user.id)
                                            .onTapGesture {
                                                viewModel.selectedUser = user
                                                showUserPreview = true
                                                selected = user.id
                                                //                                                withAnimation{
                                                //                                                    viewport = .camera(center: coordinate, zoom: 11, bearing: 0, pitch: 0)
                                                //                                                }
                                                
                                                
                                            }
                                        
                                    }
                                    
                                }
                            }
                            .padding()
                            .background(.white.opacity(0.5))
                            
                            
                          
                        }
                        
                        Text("Zoom out to see people on the map")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 15)
                            .background(
                                Capsule().fill(.white)
                                    .shadow(radius: 5)
                            )
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                }
                
                Spacer()
                
                if showUserPreview{
                    ScrollViewReader{ proxy in
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 30){
                                ForEach(viewModel.users, id: \.id){ user in
                                    
                                     
                                    MapUserPreview(user: user, path: $path, selectedUser : $selected)
                                            .environmentObject(listingViewModel)
                                            .id(user.id)
                                    
              
                                   
                                }
                            }
                            .padding(.bottom, 20)
                            .padding(.horizontal, 15)
                            
                            
                        }
                        .scrollTargetBehavior(.paging)
                        .onChange(of: selected) { oldValue, newValue in
                            if newValue != nil{
                                
                                    proxy.scrollTo(selected, anchor: .leading)
                                
                            }
                        }
                        .onAppear{
                           
                                proxy.scrollTo(selected, anchor: .leading)
                                                 }
                    }
                }
                
            }
            .onChange(of: showUserPreview) { oldValue, newValue in
                print("show user preview: \(newValue)")
                
            }
            .modifier(Navigationmodifier(path: $path))

            
        }
        
        
        
    }
    
    func convertGeoPointToCLLocationCoordinate2D(geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
}

    
    
struct  MapUserPreview: View {
    
    let user: DBUser
    @Binding var path: NavigationPath
    @EnvironmentObject var session: AuthenticationViewModel
    @EnvironmentObject var listingViewModel: ListingViewModel
    @EnvironmentObject var viewModel: MapViewModel
    let screenWidth = UIScreen.main.bounds.width
    @State var listing: Listing?
    @Binding var selectedUser: String?
    
    var body: some View{
    
        HStack{
            
            
            Button {
                selectedUser = user.id
                viewModel.selectedUser = user
                viewModel.listingViewModels[user.id] = ListingViewModel(user: user)
                
                let value = NavigationValuegeneral(type: .profile, user: user)
                path.append(value)
                
                //path.append(MapNavigationValue(type: .profile, id: "", user: user))

            } label: {
                
                VStack(alignment: .leading, spacing: 2){
                    AvatarView(photoUrl: user.photoUrl, username: user.username, size: 50)
                    Text(user.username ?? "Neighbor")
                    Text("Followers: \(user.followerNumber)")
                    Text("Following: \(user.followingNumber)")
                    Text("Joined: Jan 2024")
                    Text("Basic member")
                    
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .padding()
                .id(user.id)
            }
            
       
            
            Spacer()
            
            
            
               
                if let listing = listing{
                    
                     
                 
                        ListingCoverCellExplore(listing: listing)
                            .scaleEffect(0.7)
                            .onTapGesture {
                                selectedUser = user.id
                                
                                let value = NavigationValuegeneral(type: .mapListing, user: user, listing: listing, listingViewModel: viewModel.listingViewModels[user.id] )
                                path.append(value)
                                //path.append(MapNavigationValue(type: .listing, id: listing.id, user: user))
                            }
                    
              
     
                }else{
                    
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: screenWidth * 0.45, height: screenWidth * 0.5)
                        .scaleEffect(0.7)
                       

                        .onAppear{
                            
                            Task{
                                listing = try await  viewModel.fetchUserActiveListing(user: user)
                            }
                        }
                    
                }
            
          
        }
        .frame(width: screenWidth - 30, height: screenWidth / 2 - 30 )
        .background(.white)
        .cornerRadius(20)
        .shadow(radius: 5)
        
        
       
        
    }
}


