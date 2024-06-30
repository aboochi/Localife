//
//  MarketMapView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/12/24.
//

import SwiftUI
@_spi(Experimental) import MapboxMaps
import CoreLocation
import FirebaseFirestore
import Turf
import MapKit

struct MarketMapView: View {
    
    @EnvironmentObject var viewModel: ListingViewModel
    let listing: Listing
    let screenWidth = UIScreen.main.bounds.width
    let dimension: (CGFloat, CGFloat)
    @State var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474), zoom: 11, bearing: 0, pitch: 0)
    @State var isVisible : [String: Bool] = [:]
    @State var targetZoom : Double = 11
    @State var isInitialSetup: Bool = true
    var initialZoom: Double {if listing.destinationLocation == nil{
        return 11
    }else{
        return 18
    }
    }
    @State var currentZoom: Double = 11
    @State var originLocation: CLLocationCoordinate2D?
    @State var destinationLocation: CLLocationCoordinate2D?
    @State var midpointLocation: CLLocationCoordinate2D?
    @State var originPoint: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474)

    
    var body: some View {
        
        Map (viewport: $viewport) {
            
            if let geoPoint = listing.originLocation {
                let coordinate = convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
                
                MapViewAnnotation(coordinate: coordinate) {
                    
                    Image(systemName: "flag.fill")
                        .onAppear{
                            isVisible["origin"] = false
                            originLocation = coordinate
                                viewport = .camera(center: coordinate, zoom: initialZoom, bearing: 0, pitch: 0)
                                originPoint = coordinate
                        }
                }
                
                .onVisibilityChanged(action: { visible in
                    isVisible["origin"] = visible
                    print("origin visibilty changed: \(visible)")
                    
   
                })
                
            }
            
            if let geoPoint = listing.destinationLocation {
                let coordinate = convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
                MapViewAnnotation(coordinate: coordinate) {
                    
                    Image(systemName: "flag.checkered")
                        .onAppear{
                           
                            isVisible["destination"] = false
                            destinationLocation = coordinate
                            
                            if let geoPoint = listing.originLocation {
                                let originLocation = convertGeoPointToCLLocationCoordinate2D(geoPoint: geoPoint)
                                midpointLocation = midpointBetween(originLocation, coordinate)
                                let distance = calculateDistance(from: originLocation, to: coordinate)
                                //targetZoom = calculateZoomLevel(forDistance: distance)
                               print("distance: >>>>>>>>>>>>>>\(distance)")
                                

                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
                                    adjustCamera(midPoint: midpointBetween(originLocation, coordinate))
                                    //self.viewport = .camera(center: midpointLocation, zoom: targetZoom, bearing: 0, pitch: 0)
                                    

                                    
                                }
                            }
                       
                        }
                }
                .onVisibilityChanged(action: { visible in
                    isVisible["destination"] = visible
                    print("destination visibilty changed: \(visible)")

               
                })
            }
            
         
        }
       
        .onCameraChanged {
               
            print("zoom: \($0.cameraState.zoom)")

                }
        
        .mapStyle(.light)
        .frame(width: dimension.0, height: dimension.1)
        .onAppear{
            
            currentZoom = initialZoom
        }
        .onChange(of: isVisible) { oldValue, newValue in
           
        }
        
        
        .overlay(
            
            Button(action: {
                withViewportAnimation(.easeIn(duration: 1)) {
                    self.viewport = .camera(center: listing.destinationLocation == nil ? originPoint : midpointLocation, zoom: self.currentZoom - 0.8 , bearing: 0, pitch: 0)

                }
            }, label: {
                Image(systemName: "location.fill")
                    .scaleEffect(1)
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
            })
            
           
            .padding(10)
            
            ,alignment: .bottomTrailing
        )
        
      
        
    }
    
    
    func convertGeoPointToCLLocationCoordinate2D(geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    func adjustCamera(midPoint: CLLocationCoordinate2D) {
        if let originVisible = self.isVisible["origin"],
           let destinationVisible = self.isVisible["destination"]{
            if originVisible && destinationVisible {
                
                adjustCameraZoomIn(midPoint: midPoint)
            }else{
                adjustCameraZoomOut(midPoint: midPoint)
            }
        }
        
    }

    
    func adjustCameraZoomIn(midPoint: CLLocationCoordinate2D) {
        
        print("func zoom in called >>......")
        var index = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if index < 35 {
                if let originVisible = self.isVisible["origin"],
                   let destinationVisible = self.isVisible["destination"],
                   originVisible && destinationVisible {
                    
                   // print("adjustCamera iteration: \(index)")
                    
                    if currentZoom < 20{
                        currentZoom += 0.2
                        self.viewport = .camera(center: midPoint, zoom: self.currentZoom , bearing: 0, pitch: 0)
                        
                        
                    }
                    index += 1
                }
                else {
                    self.viewport = .camera(center: midPoint, zoom: self.currentZoom - 0.2 , bearing: 0, pitch: 0)
                    //print("else part executed >>>>>>>>>")
                    
                    timer.invalidate()
                }
            }else{
                timer.invalidate()
            }
        }
   
    }
    
    func adjustCameraZoomOut(midPoint: CLLocationCoordinate2D) {
        
        var index = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if index < 100 {
                if let originVisible = self.isVisible["origin"],
                   let destinationVisible = self.isVisible["destination"],
                   !originVisible || !destinationVisible {
                    
                   // print("adjustCamera iteration: \(index)")
                    
                    if currentZoom > 4{
                        currentZoom -= 0.2
                        self.viewport = .camera(center: midPoint, zoom: self.currentZoom , bearing: 0, pitch: 0)
                        
                        
                    }
                    index += 1
                }
                else {
                    self.viewport = .camera(center: midPoint, zoom: self.currentZoom - 0.8 , bearing: 0, pitch: 0)
                    print("else part executed >>>>>>>>>")
                    
                    timer.invalidate()
                }
            }else{
                timer.invalidate()
            }
        }
   
    }
    
    
    func midpointBetween(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lat1 = coord1.latitude.toRadians()
        let lon1 = coord1.longitude.toRadians()
        let lat2 = coord2.latitude.toRadians()
        let lon2 = coord2.longitude.toRadians()
        
        let dLon = lon2 - lon1
        
        let Bx = cos(lat2) * cos(dLon)
        let By = cos(lat2) * sin(dLon)
        
        let midLat = atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + Bx) * (cos(lat1) + Bx) + By * By))
        let midLon = lon1 + atan2(By, cos(lat1) + Bx)
        
        return CLLocationCoordinate2D(latitude: midLat.toDegrees(), longitude: midLon.toDegrees())
    }
    
    
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    
    
    
    
   
}


