//
//  FilterItemProtocol.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/29/24.
//

import Foundation

protocol FilterItemProtocol:Hashable,Equatable,Identifiable{
    static var filterType:FilterType{get}
    var name: String { get }
    var code: String { get }
    
}

enum FilterType{
    case budget
    case genre
    case specialCategory
    case specialCategory2
}
