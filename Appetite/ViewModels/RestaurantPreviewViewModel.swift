//
//  RestaurantPreviewViewModel.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/7/25.
//

import Foundation
import SwiftUI
import MapKit

final class RestaurantPreviewViewModel:ObservableObject{
    @Published var lookAroundScence:MKLookAroundScene?
    @Published var distance:Double? = nil
    let locationManger = LocationManager()
    private var restaurant:Shop?
    init(){
        getUserLocationAndDistance()
    }
    
    func getUserLocationAndDistance(){
        locationManger.onLocationUpdate = {[weak self] result in
            switch result{
            case .success(let userCoordinate):
                self?.getDistance(from: userCoordinate)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setRestaurantForViewModel(_ restaurant:Shop){
        self.restaurant = restaurant
    }
    
    //半径距離を取得
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
    
    //ストリートビュー取得
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
