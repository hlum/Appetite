//
//  NearbyRestaurantSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/26/24.
//

import SwiftUI
import MapKit
import Combine
import SDWebImageSwiftUI
//
//final class NearbyRestaurantSheetViewModel: ObservableObject {
//    @Published var searchText: String = ""
//    private var nearbyRestaurants: Binding<[Shop]>
//    private var cancellables = Set<AnyCancellable>()
//    private var cameraPosition:Binding<CLLocationCoordinate2D?>
//    
//    init(nearbyRestaurants: Binding<[Shop]>,cameraPosition:Binding<CLLocationCoordinate2D?>) {
//        self.nearbyRestaurants = nearbyRestaurants
//        self.cameraPosition = cameraPosition
//        addSubscribers()
//    }
//    
//    private func addSubscribers() {
//        $searchText
//            .debounce(for: 0.5, scheduler: DispatchQueue.main)
//            .sink { [weak self] searchText in
//                self?.fetchRestaurants(searchText: searchText)
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func fetchRestaurants(searchText: String) {
//        guard !searchText.isEmpty else{
//            return
//        }
//        guard let cameraPosition = self.cameraPosition.wrappedValue else{return}
//        HotPepperAPIClient(apiKey: APIKEY.key.rawValue).searchAllShops(
//            keyword: searchText,
//            lat:cameraPosition.latitude,
//            lon: cameraPosition.longitude
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result{
//                case .success(let restaurants):
//                    self?.nearbyRestaurants.wrappedValue = restaurants.results.shops
//                case .failure(let error):
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
//}

struct NearbyRestaurantSheetView: View {
    @Binding var restaurantsShowing: [Shop]
//    @StateObject private var vm: NearbyRestaurantSheetViewModel
    @Binding var selectedRestaurant:Shop?
    init(
        nearbyRestaurants:Binding<[Shop]>,
        cameraPosition:Binding<CLLocationCoordinate2D?>,
        selectedRestaurant:Binding<Shop?>
    ) {
        self._restaurantsShowing = nearbyRestaurants
//        self._vm = StateObject(wrappedValue: NearbyRestaurantSheetViewModel(nearbyRestaurants: nearbyRestaurants, cameraPosition: cameraPosition))
        self._selectedRestaurant = selectedRestaurant
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section{
                    LazyVStack{
                        if !restaurantsShowing.isEmpty{
                            ForEach(restaurantsShowing) { shop in
                                listItemView(for: shop)
                                    .onTapGesture {
                                        selectedRestaurant = shop
                                    }
                            }
                        }else{
                            ContentUnavailableView("検索結果に一致するものはありません。", systemImage: "magnifyingglass")
                        }
                    }
                }header: {
                    Text("レストラン一覧")
                }
            }
//            .navigationTitle("\(restaurantsShowing.count)")
        }
    }
}


extension NearbyRestaurantSheetView{
    private func listItemView(for shop:Shop) -> some View{
        HStack{
            if let logoImage = shop.logoImage,
               let url = URL(string: logoImage){
                WebImage(url: url)
                    .placeholder(content: {
                        shop.genre.image
                            .resizable()
                            .scaledToFill()
                            .frame(width:50,height:50)
                            .cornerRadius(10)
                    })
                    .resizable()
                    .scaledToFill()
                    .frame(width:50,height:50)
                    .cornerRadius(10)
                Spacer()
                VStack{
                    Text(shop.name)
                        .foregroundStyle(.systemBlack)
                        .padding()
                        .background(Color.systemWhite)
                        .cornerRadius(10)
                }
                Spacer()
            }
        }

    }
}

#Preview {
    let dummyShops = [
                Shop(
                    id: "1",
                    name: "韓国居酒屋 板橋冷麺 新大久保",
                    address: "東京都新宿区百人町１-21-4",
                    lat: 35.6895,
                    lon: 139.6917,
                    genre: Genre(code: "1", name: "居酒屋"), subGenre: SubGenre(name: "ダイニングバー", code: "fadsf"),
                    access: "2 mins from Station",
                    urls: URLs(pc: "https://example.com"),
                    photo: Photo(pc: PCPhoto(l: "large_url", m: "medium_url", s: "small_url")),
                    logoImage: "logoA.png",
                    nameKana: "レストラン A",
                    stationName: "Station A",
                    ktaiCoupon: 10,
                    budget: Budget(code: "1", name: "Affordable", average: "ランチ：～999円、ディナー：3000円～4000円", budgetMemo: "Reasonable"),
                    capacity: .integer(10),
                    wifi: "Available",
                    course: "Yes",
                    freeDrink: "No",
                    freeFood: "Yes",
                    privateRoom: "Yes",
                    open: "月～日、祝日: 11:00～15:30 （料理L.O. 15:00）17:00～23:00",
                    close: "9:00 PM",
                    parking: "Yes",
                    nonSmoking: "Yes",
                    card: "Visa"
                )
            ]
    NearbyRestaurantSheetView(nearbyRestaurants: .constant(dummyShops), cameraPosition: .constant(CLLocationCoordinate2D(latitude: 35.7020691, longitude: 139.7753269)), selectedRestaurant: .constant(dummyShops[0]))
    }

