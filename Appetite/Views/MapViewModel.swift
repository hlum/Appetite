//
//  MapViewModel.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

import Foundation
import _MapKit_SwiftUI
import SwiftUI
import Combine

final class MapViewModel:ObservableObject{
    var searchSeeingArea : Bool = false
    @Published var showFilterSheet:Bool = false
    var filterManager:FilterManger?
    @Published var selectedRestaurant:Shop? = nil
    @Published var showNearbyRestaurantSheet:Bool = true
    @Published var searchText:String = ""
    let locationManger = LocationManager()
    @Published var nearbyRestaurants:[Shop] = []
    @Published var showLocationPermissionAlert:Bool = false
    @Published var cameraPosition:MapCameraPosition = .automatic
    @Published var userLocation:CLLocationCoordinate2D?
    @Published var currentSeeingRegionCenterCoordinate:CLLocationCoordinate2D?
    var currentSeeingRegionSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @Published var fetchedFirstTime:Bool = false
    private var cancellables = Set<AnyCancellable>()

    @Published var searchedRestaurants:[Shop] = []
    
    @Published var showSearchedRestaurants: Bool = false
    
    init(filterManager:FilterManger?){
        self.filterManager = filterManager
        getUserLocationAndNearbyRestaurants()
        //NearbyRestaurantsを待つ
        DispatchQueue.main.asyncAfter(deadline: .now()+3){
            self.addSubscriberToSearchText()  //検索バーを検知する
        }
    }
    
    func setUp(_ filterManager:FilterManger){//passed the environment object from the view
        self.filterManager = filterManager
    }
        
    func getUserLocationAndNearbyRestaurants(){
        locationManger.onLocationUpdate = {[weak self] result in
            guard let self = self else{return}
            switch result{
            case .success(let userCoordinate):
                self.userLocation = userCoordinate
                if !self.fetchedFirstTime{ //画面が表示した一回目だけ
                    print("user coordinate at the first time")
                    dump(userCoordinate)
                    self.getNearbyRestaurants(at: userCoordinate)
                    fetchedFirstTime = true
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getNearbyRestaurants(at userCoordinate:CLLocationCoordinate2D,count:Int = 100){
        let apiCaller = HotPepperAPIClient(apiKey:APIKEY.key.rawValue)
        apiCaller.searchAllShops(lat: userCoordinate.latitude, lon: userCoordinate.longitude,range: 3,maxResults: count) { [weak self] result in
                switch result{
                case .success(let response):
                    DispatchQueue.main.async {
                        self?.nearbyRestaurants = response.results.shops
                    }
                case .failure(let error):
                    DispatchQueue.main.async{
                        self?.nearbyRestaurants = []
                    }
                    print(error.localizedDescription)
                }
            }
    }
    
    func moveCamera(to coordinate:CLLocationCoordinate2D,delta:Double = 0.01){
        let span = MKCoordinateSpan(
            latitudeDelta: delta,
            longitudeDelta: delta
        )
        let region = MKCoordinateRegion(
            center: coordinate,
            span: span
        )
        withAnimation(.easeIn){
            cameraPosition = .region(region)
        }
        
    }
    
}
//MARK: Filtering stuffs
extension MapViewModel{
    func searchRestaurantsWithSelectedFilters(keyword:String? = nil,budgets selectedBudgets:[Budgets],genres selectedGeneres:[Genres],selectedSpecialCategories:[SpecialCategory]){
        showSearchedRestaurants = !(filterManager?.selectedGenres.isEmpty ?? true && filterManager?.selectedBudgets.isEmpty ?? true && filterManager?.selectedSpecialCategory.isEmpty ?? true && searchText.isEmpty && !searchSeeingArea)
        print("showsearchRestaurants:\(showSearchedRestaurants)")
        //Queryがkeyword=&genre=.....のようにならないように
        let checkedKeyword: String? = (keyword?.isEmpty == false) ? keyword : nil

            //        showNearbyRestaurantSheet = selectedRestaurant == nil
        let range = calculateRange(for: currentSeeingRegionSpan)
        if let currentSeeingRegion = currentSeeingRegionCenterCoordinate{
            HotPepperAPIClient(
                apiKey: APIKEY.key.rawValue
            ).searchAllShops(
                keyword: checkedKeyword,
                lat:currentSeeingRegion.latitude,
                lon:currentSeeingRegion.longitude,
                range:range,
                genres:selectedGeneres,
                budgets: selectedBudgets,
                specialCategories: selectedSpecialCategories
                
            ) {[weak self] result in
                guard let self = self else{
                    print("lose object")
                    return
                }
                switch result{
                case .success(let response):
                    DispatchQueue.main.async{
                        print("Success")
                        withAnimation{
                            self.searchedRestaurants = response.results.shops
                            print("COUNT searchedRestaurants:\(self.searchedRestaurants.count)")
                            print("COUNT nearbyRestaurants:\(self.nearbyRestaurants.count)")
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async{
                        self.searchedRestaurants = []
                    }
                    print(error.localizedDescription)
                }
                
            }
        }else{
            print("no camera position")
        }
    }
    
    private func calculateRange(for span:MKCoordinateSpan)->Int{
        //どちらか大きい方で決める
        let maxDelta = max(span.longitudeDelta, span.latitudeDelta)
        
        //delta -> meter
        let approximateMeters = maxDelta * 111000
        print(approximateMeters)
        
        /*
        1: 300m
        2: 500m
        3: 1000m (初期値)
        4: 2000m
        5: 3000m
        */
        
        switch approximateMeters {
        case 0..<1700:      return 1
        case 1700..<2150:    return 2
        case 2150..<3000:   return 3
        case 3000..<4000:  return 4
        case 4000..<5200: return 5
        default:           return 5
        }
    }
    
    private func addSubscriberToSearchText(){
        
        $searchText
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                guard let self = self else{return}
                guard let filterManager = self.filterManager else{return}
                guard !searchText.isEmpty else{
                    //NearbyRestaurantsを取得してからそれ以降　searchTextが空になった時でも検索する
                    if self.fetchedFirstTime{
                        self.searchRestaurantsWithSelectedFilters(budgets: filterManager.selectedBudgets, genres: filterManager.selectedGenres, selectedSpecialCategories: filterManager.selectedSpecialCategory)
                    }
                    return
                }
                self.searchRestaurantsWithSelectedFilters(keyword: searchText, budgets: filterManager.selectedBudgets, genres: filterManager.selectedGenres,selectedSpecialCategories: filterManager.selectedSpecialCategory)
            }
            .store(in: &cancellables)
    }
}

