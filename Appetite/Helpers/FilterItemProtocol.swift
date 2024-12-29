//
//  FilterItemProtocol.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/29/24.
//

import Foundation

protocol FilterItemProtocol:CaseIterable,Hashable{
    var rawValue:String{get}
}
