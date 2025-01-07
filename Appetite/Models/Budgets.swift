//
//  Budgets.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

import Foundation

struct BudgetResponse:Codable{
    let results:BudgetResults
}

struct BudgetResults:Codable {
    let budgets: [BudgetFilterModel]
    
    enum CodingKeys: String, CodingKey {
        case budgets = "budget"
    }
}
//Budgetだけが違う構造だったので別のモデルを作ります。
struct BudgetFilterModel:FilterItemProtocol,Codable{
    static let filterType: FilterType = .budget
    
    let id: UUID = UUID()
    
    let code : String
    let name : String
    
    static func ==(lhs: BudgetFilterModel, rhs: BudgetFilterModel) -> Bool {
        return lhs.id == rhs.id
    }

}
