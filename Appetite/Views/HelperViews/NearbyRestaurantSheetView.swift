//
//  NearbyRestaurantSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/26/24.
//

import SwiftUI
import MapKit

struct NearbyRestaurantSheetView: View {
    @Binding var nearbyRestaurants:[Shop]
    var body: some View {
        List {
            ForEach(nearbyRestaurants) { shop in
                Text(shop.name)
            }
        }
    }
}

#Preview{
    let dummyShops = [
                Shop(
                    id: "1",
                    name: "Restaurant A",
                    address: "123 A Street, City, Country",
                    lat: 35.6895,
                    lon: 139.6917,
                    genre: Genre(code: "1", name: "Japanese"),
                    access: "2 mins from Station",
                    urls: URLs(pc: "https://example.com"),
                    photo: Photo(pc: PCPhoto(l: "large_url", m: "medium_url", s: "small_url")),
                    logoImage: "logoA.png",
                    nameKana: "レストラン A",
                    stationName: "Station A",
                    ktaiCoupon: 10,
                    budget: Budget(code: "1", name: "Affordable", average: "$20", budgetMemo: "Reasonable"),
                    capacity: .string("10"),
                    wifi: "Available",
                    course: "Yes",
                    freeDrink: "No",
                    freeFood: "Yes",
                    privateRoom: "Yes",
                    open: "10:00 AM",
                    close: "9:00 PM",
                    parking: "Yes",
                    nonSmoking: "Yes",
                    card: "Visa"
                )
            ]
    NearbyRestaurantSheetView(nearbyRestaurants: .constant(dummyShops))
        }
