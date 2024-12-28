//
//  NearbyRestaurantSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/26/24.
//

import SwiftUI
import MapKit
import Combine

final class NearbyRestaurantSheetViewModel: ObservableObject {
    @Published var searchText: String = ""
    private var nearbyRestaurants: Binding<[Shop]>
    private var cancellables = Set<AnyCancellable>()
    private var cameraPosition:Binding<CLLocationCoordinate2D?>
    
    init(nearbyRestaurants: Binding<[Shop]>,cameraPosition:Binding<CLLocationCoordinate2D?>) {
        self.nearbyRestaurants = nearbyRestaurants
        self.cameraPosition = cameraPosition
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.fetchRestaurants(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func fetchRestaurants(searchText: String) {
        guard !searchText.isEmpty else{
            return
        }
        guard let cameraPosition = self.cameraPosition.wrappedValue else{return}
        HotPepperAPIClient(apiKey: APIKEY.key.rawValue).searchShops(
            keyword: searchText,
            lat:cameraPosition.latitude,
            lon: cameraPosition.longitude,
            count: 100
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let restaurants):
                    self?.nearbyRestaurants.wrappedValue = restaurants.results.shops
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct NearbyRestaurantSheetView: View {
    @Binding var restaurantsShowing: [Shop]
    @StateObject private var vm: NearbyRestaurantSheetViewModel
    var showSearchedRestaurants:Bool
    
    init(nearbyRestaurants: Binding<[Shop]>,cameraPosition:Binding<CLLocationCoordinate2D?>,showSearchedRestaurants:Bool) {
        self._restaurantsShowing = nearbyRestaurants
        self._vm = StateObject(wrappedValue: NearbyRestaurantSheetViewModel(nearbyRestaurants: nearbyRestaurants, cameraPosition: cameraPosition))
        self.showSearchedRestaurants = showSearchedRestaurants
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(restaurantsShowing) { shop in
                    Text(shop.name)
                        .foregroundStyle(.systemBlack)
                }
            }
            .navigationTitle(showSearchedRestaurants ? "検索結果 \(restaurantsShowing.count)個" : "近所のレストラン一覧")
        }
    }
}

//#Preview{
//    let dummyShops = [
//                Shop(
//                    id: "1",
//                    name: "Restaurant A",
//                    address: "123 A Street, City, Country",
//                    lat: 35.6895,
//                    lon: 139.6917,
//                    genre: Genre(code: "1", name: "Japanese"),
//                    access: "2 mins from Station",
//                    urls: URLs(pc: "https://example.com"),
//                    photo: Photo(pc: PCPhoto(l: "large_url", m: "medium_url", s: "small_url")),
//                    logoImage: "logoA.png",
//                    nameKana: "レストラン A",
//                    stationName: "Station A",
//                    ktaiCoupon: 10,
//                    budget: Budget(code: "1", name: "Affordable", average: "$20", budgetMemo: "Reasonable"),
//                    capacity: .string("10"),
//                    wifi: "Available",
//                    course: "Yes",
//                    freeDrink: "No",
//                    freeFood: "Yes",
//                    privateRoom: "Yes",
//                    open: "10:00 AM",
//                    close: "9:00 PM",
//                    parking: "Yes",
//                    nonSmoking: "Yes",
//                    card: "Visa"
//                )
//            ]
//    NearbyRestaurantSheetView(nearbyRestaurants: .constant(dummyShops))
//        }
