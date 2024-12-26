//
//  Restaurant.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import Foundation

struct HotPepperResponse: Codable {
    let results: Results
}

struct Results: Codable {
    let apiVersion: String
    let resultsAvailable: Int
    let resultsReturned: String
    let resultsStart: Int
    let shops: [Shop]
    
    enum CodingKeys: String, CodingKey {
        case apiVersion = "api_version"
        case resultsAvailable = "results_available"
        case resultsReturned = "results_returned"
        case resultsStart = "results_start"
        case shops = "shop"
    }
}

struct Shop: Codable,Identifiable {
    let id: String
    let name: String
    let address: String
    let lat: Double
    let lon: Double
    let genre: Genre
    let access: String
    let urls: URLs
    let photo: Photo
    
    let logoImage: String?
    let nameKana: String?
    let stationName: String?
    let ktaiCoupon: Int?
    let budget: Budget?
    let capacity: Int?
    let wifi: String?
    let course: String?
    let freeDrink: String?
    let freeFood: String?
    let privateRoom: String?
    let open: String?
    let close: String?
    let parking: String?
    let nonSmoking: String?
    let card: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, lat, genre, access, urls, photo
        case lon = "lng"
        case logoImage = "logo_image"
        case nameKana = "name_kana"
        case stationName = "station_name"
        case ktaiCoupon = "ktai_coupon"
        case budget, capacity, wifi, course
        case freeDrink = "free_drink"
        case freeFood = "free_food"
        case privateRoom = "private_room"
        case open, close, parking
        case nonSmoking = "non_smoking"
        case card
    }
}

struct Genre: Codable {
    let code: String
    let name: String
}

struct Budget: Codable {
    let code: String
    let name: String
    let average: String
    let budgetMemo: String?
    
    enum CodingKeys: String, CodingKey {
        case code, name, average
        case budgetMemo = "budget_memo"
    }
}

struct URLs: Codable {
    let pc: String
}

struct Photo: Codable {
    let pc: PCPhoto
}

struct PCPhoto: Codable {
    let l: String
    let m: String
    let s: String
}
