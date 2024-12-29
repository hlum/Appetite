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
    
    var showSearchedRestaurants: Bool = false
    
    init(filterManager:FilterManger?){
        self.filterManager = filterManager
        addSubscriberToSearchText()
        getUserLocationAndNearbyRestaurants()
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
                    self.getNearbyRestaurants(at: userCoordinate,count: 50)
                    fetchedFirstTime = true
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getNearbyRestaurants(at userCoordinate:CLLocationCoordinate2D,count:Int = 10){
        let apiCaller = HotPepperAPIClient(apiKey:APIKEY.key.rawValue)
        apiCaller.searchShops(lat: userCoordinate.latitude, lon: userCoordinate.longitude,range: 3,count: count) { [weak self] result in
                switch result{
                case .success(let response):
                    DispatchQueue.main.async {
                        self?.nearbyRestaurants = response.results.shops
                    }
                case .failure(let error):
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
    func searchRestaurantsWithSelectedFilters(keyword:String? = nil,budgets selectedBudgets:[Budgets],genres selectedGeneres:[Genres]){
        showSearchedRestaurants = true
        showNearbyRestaurantSheet = selectedRestaurant == nil
        let range = calculateRange(for: currentSeeingRegionSpan)
        if let currentSeeingRegion = currentSeeingRegionCenterCoordinate{
            HotPepperAPIClient(
                apiKey: APIKEY.key.rawValue
            ).searchShops(
                keyword: keyword,
                lat:currentSeeingRegion.latitude,
                lon:currentSeeingRegion.longitude,
                range:range,
                genres:selectedGeneres,
                budgets: selectedBudgets,
                count: 100
                
            ) {[weak self] result in
                
                switch result{
                case .success(let response):
                    DispatchQueue.main.async{
                        print("Success")
                        withAnimation{
                            self?.searchedRestaurants = response.results.shops
                        }
//                        dump(self?.searchedRestaurants)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
        }else{
            print("no camera position")
        }
    }
    
    private func calculateRange(for span:MKCoordinateSpan)->Int{
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
            case 0..<1700:      return 1    // Very zoomed in (< 400m viewable)
            case 1700..<2150:    return 2   // Zoomed in enough to see a few blocks
            case 2150..<3000:   return 3   // Medium zoom, good for neighborhood view
            case 3000..<4000:  return 4    // Zoomed out to see multiple neighborhoods
            case 4000..<5200: return 5
            default:           return 5    // Very zoomed out, city-level view
        }
    }
    
    private func addSubscriberToSearchText(){
        $searchText
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                guard let self = self else{return}
                guard !self.searchText.isEmpty else{return}
                guard let filterManager = self.filterManager else{return}
                self.searchRestaurantsWithSelectedFilters(keyword: searchText, budgets: filterManager.selectedBudgets, genres: filterManager.selectedGenres)
            }
            .store(in: &cancellables)
    }
}

