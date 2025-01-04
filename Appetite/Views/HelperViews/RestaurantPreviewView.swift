//
//  RestaurantPreviewView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/26/24.
//

import SwiftUI
import SDWebImageSwiftUI
import CoreLocation
import MapKit

final class RestaurantPreviewViewModel:ObservableObject{
    @Published var lookAroundScence:MKLookAroundScene?
    @Published var distance:Double? = nil
    let locationManger = LocationManager()
    private var restaurant:Shop?
    init(){
        locationManger.onLocationUpdate = {[weak self] result in
            switch result{
            case .success(let userCoordinate):
                self?.getDistance(from: userCoordinate)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setRestaurant(_ restaurant:Shop){
        self.restaurant = restaurant
    }
    
    private func getDistance(from userCoordinate:CLLocationCoordinate2D){
        guard let restaurantLon = restaurant?.lon,
              let restaurantLat = restaurant?.lat else{
            print("can't get the restaurant coordinates")
            return
        }
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let shopLocation = CLLocation(latitude: restaurantLat, longitude: restaurantLon)
        
        self.distance = userLocation.distance(from: shopLocation)/1000
    }
    
    @MainActor
    func fetchLookAroundScene()async{
        guard let restaurant = self.restaurant else{return}
        let coordinate = CLLocationCoordinate2D(
            latitude: restaurant.lat,
            longitude: restaurant.lon
        )
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        lookAroundScence = try? await request.scene
        
    }


}

struct RestaurantPreviewView: View {
    @StateObject private var vm = RestaurantPreviewViewModel()
    let selectedRestaurant:Shop
    @Binding var showDetailSheetView:Bool
    @Binding var showRoutesSheet:Bool
    var body: some View {
        HStack(alignment:.bottom,spacing: 0){
                VStack(alignment:.leading,spacing: 16){
                    imageSection
                    
                    titleSection
                        .onTapGesture {
                            showDetailSheetView = true
                        }

                }
            
                VStack(spacing: 8) {
                    Button {
                        showRoutesSheet = true
                    } label: {
                        Text("経路")
                            .font(.headline)
                            .foregroundStyle(.systemWhite)
                            .frame(width: 125,height:35)
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        showDetailSheetView = true
                    } label: {
                        Text("詳細")
                            .font(.headline)
                            .foregroundStyle(.systemWhite)
                            .frame(width: 125,height:35)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)

                }
            }
        .overlay(alignment: .topTrailing, content: {
            
            LookAroundPreview(scene: $vm.lookAroundScence)
                .frame(width:80,height:80)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.systemWhite, lineWidth: 5) // Add border
                )
                .shadow(color:.systemWhite,radius:1,y:2)
                .offset(y:-20)
        })
            .onAppear{
                vm.setRestaurant(selectedRestaurant)
                Task{
                    await vm.fetchLookAroundScene()
                }
            }
            .padding(20)
            .foregroundStyle(.systemBlack)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.systemWhite)
                    .offset(y:85)
                    .onTapGesture {
                        showDetailSheetView = true
                    }
            )
            .cornerRadius(30)

    }
}


extension RestaurantPreviewView{
    private var imageSection:some View{
        ZStack{
            if let photoURLString = selectedRestaurant.logoImage,
               let photoURL = URL(string:photoURLString){
                WebImage(url: photoURL)
                    .placeholder(content: {
                        selectedRestaurant.genre.image
                            .resizable()
                            .scaledToFill()
                            .frame(width:100,height:100)
                            .cornerRadius(10)
                    })
                    .resizable()
                    .scaledToFit()
                    .frame(width:100,height:100)
                    .cornerRadius(10)
            }else{
                selectedRestaurant.genre.image
                    .resizable()
                    .scaledToFill()
                    .frame(width:100,height:100)
                    .cornerRadius(10)
            }
        }
        .padding(6)
        .background(.systemWhite)
        .cornerRadius(10)
    }
    
    private var titleSection:some View{
        
        VStack(alignment: .leading){
            Text(selectedRestaurant.name)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(2)
            
            openTime
            
            Text("\(selectedRestaurant.genre.name)\n\(selectedRestaurant.subGenre?.name ?? "")")
                .font(.subheadline)
                .bold()
            if let distance = vm.distance{
                let distanceInString = String(format: "%.2f", distance).replacingOccurrences(of: "\\.0$", with: "", options: .regularExpression)
                Text("半径距離")
                    .font(.caption)
                    .bold()
                Text("\(distanceInString)km")
                    .font(.caption2)
            }else{
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
        
    }
    
    private var openTime:some View{
        ZStack{
            if let openTime = selectedRestaurant.open,
               //全角文字　→ 半角に変換
               let normalizedOpenTime = openTime.applyingTransform(.fullwidthToHalfwidth, reverse: false){
                // index of "(" in
                //月～水: 11:00～23:00 （料理L.O. 22:20 ドリンクL.O. 22:20）木～日: 11:00～23:00 （料理L.O. 22:20 ドリンクL.O. 22:00）祝日: 11:00～23:00 （料理L.O. 22:00 ドリンクL.O. 22:00）
                if let index = normalizedOpenTime.firstIndex(of: "(") {
                    let result = normalizedOpenTime[..<index]
                    Text(result)
                        .font(.subheadline)
                        .bold()
                } else {
                    Text("営業時間は不明です")
                        .font(.subheadline)
                }
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
                    photo: Photo(pc: PCPhoto(l: "large_url", m: "medium_url", s: "small_url"), mobile: MobilePhoto(l: "large", s: "small")), catchPharse: "fadf",
                    logoImage: "logoA.png",
                    nameKana: "レストラン A",
                    stationName: "Station A",
                    ktaiCoupon: 10,
                    budget: Budget(code: "1", name: "Affordable", average: "ランチ：～999円、ディナー：3000円～4000円", budgetMemo: "Reasonable"), partyCapacity: .string("10"),
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
    RestaurantPreviewView(
        selectedRestaurant: dummyShops[0],
        showDetailSheetView: .constant(
            false
        ),
        showRoutesSheet: .constant(
            false
        )
    )
}
