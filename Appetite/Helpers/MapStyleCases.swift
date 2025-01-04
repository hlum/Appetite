//
//  MapStyleCases.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

import Foundation
//MapStyleはEquatableじゃないから判定できるようにカスタムで作る
enum MapStyleCases:Int{
    case hybrid = 1
    case standard = 2
    
    var label:String{
        switch self{
        case .hybrid:
            "航空写真"
        case .standard:
            "標準"
        }
    }
}
