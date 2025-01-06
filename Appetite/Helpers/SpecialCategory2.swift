//
//  SpecialCategory2.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/30/24.
//

import Foundation

struct SpecialCategory2Response:Codable{
    let results:SpecialCategory2Results
}
struct SpecialCategory2Results: Codable {
    let specialCategories: [SpecialCategory2]
    
    enum CodingKeys: String, CodingKey {
        case specialCategories = "special_category"
    }
}

struct SpecialCategory2: Codable,FilterItemProtocol {
    static var filterType: FilterType = .specialCategory2
    let id:UUID = UUID()
    let code: String
    let name: String
    
    static func ==(lhs: SpecialCategory2, rhs: SpecialCategory2) -> Bool {
        return lhs.code == rhs.code
    }

}
