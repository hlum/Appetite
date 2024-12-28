//
//  Restaurant.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import Foundation
import SwiftUICore

struct HotPepperResponse: Codable {
    let results: Results
}

struct Results: Codable {
    let apiVersion: String
    let resultsAvailable: Int?
    let resultsReturned: String?
    let resultsStart: Int?
    let shops: [Shop]
    
    enum CodingKeys: String, CodingKey {
        case apiVersion = "api_version"
        case resultsAvailable = "results_available"
        case resultsReturned = "results_returned"
        case resultsStart = "results_start"
        case shops = "shop"
    }
}

struct Shop: Codable,Identifiable,Equatable {
    static func == (lhs: Shop, rhs: Shop) -> Bool {
        lhs.id == rhs.id
    }
    
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
    let capacity: Capacity?
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

enum Capacity: Codable {
    case integer(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .integer(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(Capacity.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected Int or String for capacity"
            ))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let intValue):
            try container.encode(intValue)
        case .string(let stringValue):
            try container.encode(stringValue)
        }
    }
}

struct Genre: Codable {
    let code: String
    let name: String
    var image: Image {
        switch code {
//        case "G001":
//            return "izakaya"
//        case "G002":
//            return "dining_bar"
//        case "G003":
//            return "creative_cuisine"
//        case "G004":
//            return "japanese_food"
//        case "G005":
//            return "western_food"
//        case "G006":
//            return "italian_french"
//        case "G007":
//            return "chinese_food"
//        case "G008":
//            return "yakiniku"
//        case "G017":
//            return "korean_food"
//        case "G009":
//            return "asian_ethnic_food"
//        case "G010":
//            return "international_cuisine"
//        case "G011":
//            return "karaoke_party"
//        case "G012":
//            return "bar_cocktail"
//        case "G013":
//            return "ramen"
//        case "G016":
//            return "okonomiyaki_manjya"
//        case "G014":
//            return "cafe_sweets"
//        case "G015":
//            return "other_gourmet"
        default:
            Image(systemName: "fork.knife.circle")
        }
    }
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
