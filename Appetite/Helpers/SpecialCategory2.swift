//
//  SpecialCategory2.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/30/24.
//

import Foundation

enum SpecialCategory2: String,FilterItemProtocol {
    static var filterType: FilterType = .specialCategory2
    
    case SPD8 = "ランチを楽しむ"
    case SPF9 = "大人なグルメ"
    case SPG1 = "デートにぴったり"
    case SPF8 = "おすすめコース"
    case SPG7 = "こだわり食材"
    case SPG8 = "旬の料理を楽しむ"
    case SPF7 = "飲み放題付コース"
    case SPG3 = "ママにもやさしい"
    case SPG4 = "個室・貸切・設備で探す"
    case SPG5 = "特別シーンなら"
    case SPG2 = "女性に嬉しい"
    case SPG6 = "定番おすすめ"
    case SPG9 = "季節のイベント"
    
    var name: String {
        return self.rawValue
    }

    var code: String {
        return String(describing: self)
    }
}
