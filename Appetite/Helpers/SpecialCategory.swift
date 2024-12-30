//
//  SpecialCategory.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/30/24.
//

import Foundation

enum SpecialCategory: String,FilterItemProtocol {
    static var filterType: FilterType = .specialCategory
    
    case LT0089 = "食べ放題プランのあるお店"
    case LT0090 = "コースじゃなくても飲み放題OKなお店"
    case LU0017 = "食事メインで楽しめるお店"
    case LU0011 = "雰囲気がいいBAR"
    case LZ0001 = "サムギョプサル、サムゲタン…美味しい韓国料理を味わう！"
    case LZ0002 = "おいしく飲んで食べられるバル・ビストロ"
    case LU0051 = "梅酒・果実酒・カクテルの種類が豊富なお店"
    case LU0053 = "郷土料理・ご当地メニュー！"
    case LY0090 = "話題のB級グルメを味わう"
    case LU0055 = "地鶏・焼き鳥・焼きとんを食べたい！"
    case LZ0005 = "中華・アジアン・各国料理"
    case LZ0028 = "ハッピーアワーでオトクに楽しむ"
    case LZ0029 = "こだわりの絶品ラーメンのあるお店"
    
    var name:String{
        self.rawValue
    }
    
    var code:String{
        String(describing: self)
    }

}

