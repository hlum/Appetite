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
    let subGenre:SubGenre?
    let access: String
    let urls: URLs
    let photo: Photo
    let catchPharse:String
    
    let logoImage: String?
    let nameKana: String?
    let stationName: String?
    let ktaiCoupon: Int?
    let budget: Budget?
    let partyCapacity:PartyCapacity?
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
        case partyCapacity = "party_capacity"
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
        case subGenre = "sub_genre"
        case catchPharse = "catch"
    }
}

enum PartyCapacity:Codable{
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
                debugDescription: "Expected Int or String for partyCapacity"
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
    
    // Computed property for a readable string
    var displayValue: String {
        switch self {
        case .integer(let intValue):
            return "\(intValue)"
        case .string(let stringValue):
            return stringValue
        }
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
    
    // Computed property for a readable string
    var displayValue: String {
        switch self {
        case .integer(let intValue):
            return "\(intValue)"
        case .string(let stringValue):
            return stringValue
        }
    }
}

struct SubGenre:Codable{
    let name:String
    let code:String
}
struct Genre: FilterItemProtocol,Codable {
    static var filterType: FilterType = .genre
    let id:UUID = UUID()
    let code: String
    let name: String
    var image: Image {
        switch code {
        case "G001":
            return Image(.izakaya)
        case "G002":
            return Image(.diningBar)
        case "G003":
            return Image(.creativeCuisine)
        case "G004":
            return Image(.japaneseFood)
        case "G005":
            return Image(.westernFood)
        case "G006":
            return Image(.italianFrench)
        case "G007":
            return Image(.chineseFood)
        case "G008":
            return Image(.yakiniku)
        case "G017":
            return Image(.koreanFood)
        case "G009":
            return Image(.asian)
        case "G010":
            return Image(.international)
        case "G011":
            return Image(.karaoke)
        case "G012":
            return Image(.barCocktail)
        case "G013":
            return Image(.ramen)
        case "G016":
            return Image(.okonomiyaki)
        case "G014":
            return Image(.cafe)
        case "G015":
            return Image(systemName: "fork.knife")
        default:
            return Image(systemName: "fork.knife")
        }
    }
    
    static func ==(lhs: Genre, rhs: Genre) -> Bool {
        return lhs.code == rhs.code
    }

}


struct Budget:Codable {
    
    static var filterType: FilterType = .budget
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
    let mobile:MobilePhoto
}

struct MobilePhoto:Codable{
    let l:String
    let s:String
}
struct PCPhoto: Codable {
    let l: String
    let m: String
    let s: String
}
