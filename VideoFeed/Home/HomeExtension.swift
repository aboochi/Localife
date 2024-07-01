//
//  HomeExtension.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/13/24.
//

import SwiftUI

extension HomeView{
    
    func updateNavigation(oldValue: Int, newValue: Int){
        

        if oldValue == 0 && newValue == 0{
            if homeIndex.feedViewIsAppear{
                scrollToTop = true
            }
            path = NavigationPath()
            homeIndex.dismissNotificationView = true
            homeIndex.isSearchExpanded = false
            
        }else if oldValue == 1 && newValue == 1{
            
            
            switch homeIndex.marketcurrentPage{
                
            case .expired:
                if  !homeIndex.marketExpiredGoTop{
                    
                    homeIndex.marketExpiredGoTop = true
                }else{
                    marketPath = NavigationPath()
                }
            case .active:
                if  !homeIndex.marketActiveGoTop{
                    
                    homeIndex.marketActiveGoTop = true
                }else{
                    marketPath = NavigationPath()
                }
            case .explore:
                if  !homeIndex.marketExploreGoTop{
                    
                    homeIndex.marketExploreGoTop = true
                }else{
                    marketPath = NavigationPath()
                }
            case .otherUser:
                if  !homeIndex.marketOtherUserGoTop{
                    
                    homeIndex.marketOtherUserGoTop = true
                }else{
                    marketPath = NavigationPath()
                }
            case .interest:
                if  !homeIndex.marketInterestedGoTop{
                    
                    homeIndex.marketInterestedGoTop = true
                }else{
                    marketPath = NavigationPath()
                }
            case .main:
                if  !homeIndex.marketMainGoTop{
                    
                    homeIndex.marketMainGoTop = true
                }else{
                    marketPath = NavigationPath()
                }
                
            case .full:
                
                marketPath = NavigationPath()
                
            case .keywordSearch:
                marketPath = NavigationPath()
            }
            
        }else if  oldValue == 3 && newValue == 3{
                
                mapPath = NavigationPath()
           
            
        }else if  oldValue == 4 && newValue == 4{
            
            profilePath = NavigationPath()
            
            if   homeIndex.feedViewIsAppear == true{
                
                homeIndex.profileScrollTotop = true
            }else{
                homeIndex.feedViewIsAppear = true
        }

            
        }
    }
    
}


extension Binding {
    func onUpdate(_ closure: @escaping (Value, Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { newValue in
                let oldValue = self.wrappedValue
                self.wrappedValue = newValue
                closure(oldValue, newValue)
            }
        )
    }
}


class HomeIndex: ObservableObject {
    @Published var currentIndex = 0
    @Published var chatTargetUser: DBUser?
    @Published var listing: Listing?
    @Published var messageFrom: MessageFromEnum = .profile
    
    @Published var marketMainGoTop: Bool = true
    @Published var marketExploreGoTop: Bool = true
    @Published var marketInterestedGoTop: Bool = true
    @Published var marketExpiredGoTop: Bool = true
    @Published var marketActiveGoTop: Bool = true
    @Published var marketOtherUserGoTop: Bool = true
    @Published var marketcurrentPage: ListingTypeEnum = .main
    @Published var marketPreviousPage: ListingTypeEnum = .main
    
    @Published var dismissNotificationView: Bool = false
    @Published var isSearchExpanded: Bool = false
    @Published var feedViewIsAppear: Bool = true
    @Published var profileScrollTotop: Bool = false
    
    @Published var closedChatId: String? = nil


    
    static let shared = HomeIndex()
    
    private init() {}
}

enum MarketNavigationEnum: String{
    case yourInterest =  "yourInterest"
    case yourListing = "yourListing"
    case smallCell = "smallCell"
    case keywordSearch = "search"
}


enum MessageFromEnum{
    case listing
    case profile
}
