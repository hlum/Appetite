//
//  SpecialCategory.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/30/24.
//

import Foundation

struct SpecialCategoryResponse:Codable{
    let results:SpecialCategoryResults
}

struct SpecialCategoryResults: Codable {
    let specials: [SpecialCategory]
    
    enum CodingKeys: String, CodingKey {
        case specials = "special"
    }
}

struct SpecialCategory:FilterItemProtocol, Codable {
    static var filterType: FilterType = .specialCategory
    let id:UUID = UUID()
    let code: String
    let name: String
    
    static func ==(lhs: SpecialCategory, rhs: SpecialCategory) -> Bool {
        return lhs.code == rhs.code
    }

}
