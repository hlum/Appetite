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
    //UI STUFFS
    @Published var showAiResultSheet:Bool = false
    @Published var showNearbyRestaurantSheet:Bool = true
    @Published var showRoutesSheet:Bool = false
    @Published var showFilterSheet:Bool = false
    @Published var showDetailSheetView:Bool = false
    
    @Published var showLocationPermissionAlert:Bool = false
    @Published var showAlert:Bool = false
    @Published var alertMessage:String = ""
    
    @Published var searchText:String = ""
    @Published var progress:Double = 0.1

    @Published var showSearchedRestaurants: Bool = false
    @Published var selectedRestaurant:Shop? = nil
    @Published var nearbyRestaurants:[Shop] = []
    @Published var searchedRestaurants:[Shop] = []
    
    //ROUTES STUFFS
    @Published var transportType:MKDirectionsTransportType = .automobile
    @Published var availableRoutes:[MKRoute] = []
    @Published var selectedRoute:MKRoute? = nil
        
    
    //OBJECTS
    weak var filterManager:FilterManager?
    private let apiClient:HotPepperAPIClient
    let locationManager = LocationManager()
    
    //LOCATION STUFFS
    var searchSeeingArea : Bool = false
    @Published var cameraPosition:MapCameraPosition = .automatic
    @Published var userLocation:CLLocationCoordinate2D?
    @Published var currentSeeingRegionCenterCoordinate:CLLocationCoordinate2D?
    var currentSeeingRegionSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    
    
    @Published var fetchedFirstTime:Bool = false//FLAG
    private var cancellables = Set<AnyCancellable>()
    
    init(filterManager:FilterManager?){
        self.apiClient = HotPepperAPIClient(apiKey: APIKEY.hotpepperApiKey.rawValue)
        self.filterManager = filterManager
        getUserLocationAndNearbyRestaurants()
        self.addSubscriberToSearchText()  //検索バーを検知する

    }

    deinit{
        locationManager.onLocationUpdate = nil
        cancellables.removeAll()
    }
    
    func setUp(_ filterManager:FilterManager){//passed the environment object from the view
        self.filterManager = filterManager
    }
      
    
    private func checkForCustomError(error:Error){
        if let customError = error as? CustomErrors{
            self.showLocationPermissionAlert = true
            self.showAlert(for: customError.localizedDescription)
        }else{
            self.showAlert(for: error.localizedDescription)
        }
    }
    
    private func showAlert(for message:String){
        DispatchQueue.main.async {
            if !self.showAlert{
                self.showAlert = true
                self.alertMessage = message
            }
            print("Alert state: \(self.showAlert)")
        }
    }
    
    func getUserLocationAndNearbyRestaurants(){
        locationManager.onLocationUpdate = {[weak self] result in
            guard let self = self else{return}
            switch result{
            case .success(let userCoordinate):
                self.userLocation = userCoordinate
                if !self.fetchedFirstTime{ //画面が表示した一回目だけ
                    self.getNearbyRestaurants(at: userCoordinate)
                    fetchedFirstTime = true
                }
            case .failure(let error):
                checkForCustomError(error: error)
                print(error.localizedDescription)
            }
        }
    }
    
    private func getNearbyRestaurants(at userCoordinate:CLLocationCoordinate2D,count:Int = 100){
        self.apiClient.searchAllShops(lat: userCoordinate.latitude, lon: userCoordinate.longitude,range: 3,maxResults: count) { [weak self] result in
                switch result{
                case .completed(let response):
                    DispatchQueue.main.async {
                        self?.nearbyRestaurants = response.results.shops
                        self?.progress = 1.0
                    }
                case .progress(let progress):
                    DispatchQueue.main.async {
                        self?.progress = progress
                    }
                case .error(let error):
                    DispatchQueue.main.async{
                        self?.nearbyRestaurants = []
                        self?.progress = 1.0
                    }
                    self?.checkForCustomError(error: error)
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

//MARK: View Functions
extension MapViewModel{
    func showRestaurant(restaurant:Shop){
        withAnimation(.bouncy) {
            selectedRestaurant = restaurant
        }
    }
}

//MARK: Filtering stuffs
extension MapViewModel{
    
    func searchRestaurantsWithSelectedFilters(
        keyword:String? = nil,
        budgets selectedBudgets:[BudgetFilterModel],
        genres selectedGeneres:[Genre],
        selectedSpecialCategories:[SpecialCategory],
        selectedSpecialCategory2:[SpecialCategory2]
    ){
        showSearchedRestaurants = !(filterManager?.selectedGenres.isEmpty ?? true &&
                                    filterManager?.selectedBudgetFilterModels.isEmpty ?? true &&
                                    filterManager?.selectedSpecialCategory.isEmpty ?? true &&
                                    filterManager?.selectedSpecialCategory2.isEmpty ?? true &&
                                    searchText.isEmpty && !searchSeeingArea)
        //Queryがkeyword=&genre=.....のようにならないように
        let checkedKeyword: String? = (keyword?.isEmpty == false) ? keyword : nil

            //        showNearbyRestaurantSheet = selectedRestaurant == nil
        let range = calculateRange(for: currentSeeingRegionSpan)
        if let currentSeeingRegion = currentSeeingRegionCenterCoordinate{
            apiClient.searchAllShops(
                keyword: checkedKeyword,
                lat:currentSeeingRegion.latitude,
                lon:currentSeeingRegion.longitude,
                range:range,
                genres:selectedGeneres,
                budgets: selectedBudgets,
                specialCategories: selectedSpecialCategories,
                specialCategories2 : selectedSpecialCategory2
                
            ) {[weak self] result in
                guard let self = self else{
                    return
                }
                switch result{
                case .completed(let response):
                    DispatchQueue.main.async{
                        withAnimation{
                            self.searchedRestaurants = response.results.shops
                            self.progress = 1.0
                        }
                    }
                case .progress(let progress):
                    DispatchQueue.main.async{
                        self.progress = progress
                    }
                case .error(let error):
                    DispatchQueue.main.async{
                        self.searchedRestaurants = []
                        self.progress = 1.0
                        self.checkForCustomError(error: error)
                    }
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
                        self.searchRestaurantsWithSelectedFilters(
                            budgets: filterManager.selectedBudgetFilterModels,
                            genres: filterManager.selectedGenres,
                            selectedSpecialCategories: filterManager.selectedSpecialCategory,
                            selectedSpecialCategory2: filterManager.selectedSpecialCategory2
                        )
                    }
                    return
                }
                self.searchRestaurantsWithSelectedFilters(
                    keyword: searchText,
                    budgets: filterManager.selectedBudgetFilterModels,
                    genres: filterManager.selectedGenres,
                    selectedSpecialCategories: filterManager.selectedSpecialCategory,
                    selectedSpecialCategory2: filterManager.selectedSpecialCategory2
                )
            }
            .store(in: &cancellables)
    }
}


//MARK: Routes
extension MapViewModel{
    func getAvailableRoutes(){
        let request = MKDirections.Request()
        guard let userLocation = self.userLocation else{
            print("Can't get user Location For the route")
            return
        }
        guard let selectedRestaurant = selectedRestaurant else{
            print("NO selected Restaurant for destination")
            return
        }
        let destinationCoordinate = CLLocationCoordinate2D(latitude: selectedRestaurant.lat, longitude: selectedRestaurant.lon)
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = transportType
        request.requestsAlternateRoutes = true // Request multiple routes
        
        Task{
            do{
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                withAnimation {
                    DispatchQueue.main.async{
                        self.availableRoutes = response.routes
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    self.availableRoutes = []
                }
                print("Error getting directions:\(error.localizedDescription)")
            }
        }
    }
    
    
    func getRouteUpdate(){
        let request = MKDirections.Request()
        guard let userLocation = self.userLocation else{
            print("Can't get user Location For the route")
            return
        }
        guard let selectedRestaurant = selectedRestaurant else{
            print("NO selected Restaurant for destination")
            return
        }
        let destinationCoordinate = CLLocationCoordinate2D(latitude: selectedRestaurant.lat, longitude: selectedRestaurant.lon)
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = transportType
        request.requestsAlternateRoutes = true // Request multiple routes
        
        Task{
            do{
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                withAnimation {
                    DispatchQueue.main.async{
                        self.selectedRoute = response.routes.first
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    self.availableRoutes = []
                }
                print("Error getting directions:\(error.localizedDescription)")
            }
        }
    }
    
    func updateRoute(){
        //5m移動したら
        locationManager.onLocationUpdate = {[weak self] _ in
            if let userLocation = self?.userLocation{
                self?.moveCamera(to: userLocation)
            }
            self?.updateRoute()
        }
    }
    
}