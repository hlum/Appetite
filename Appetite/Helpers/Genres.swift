//
//  Genres.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

enum Genres: String, CaseIterable {
    case G001 = "居酒屋"
    case G002 = "ダイニングバー・バル"
    case G003 = "創作料理"
    case G004 = "和食"
    case G005 = "洋食"
    case G006 = "イタリアン・フレンチ"
    case G007 = "中華"
    case G008 = "焼肉・ホルモン"
    case G017 = "韓国料理"
    case G009 = "アジア・エスニック料理"
    case G010 = "各国料理"
    case G011 = "カラオケ・パーティ"
    case G012 = "バー・カクテル"
    case G013 = "ラーメン"
    case G016 = "お好み焼き・もんじゃ"
    case G014 = "カフェ・スイーツ"
    case G015 = "その他グルメ"

    var name: String {
        return self.rawValue
    }

    var code: String {
        switch self {
        case .G001: return "G001"
        case .G002: return "G002"
        case .G003: return "G003"
        case .G004: return "G004"
        case .G005: return "G005"
        case .G006: return "G006"
        case .G007: return "G007"
        case .G008: return "G008"
        case .G017: return "G017"
        case .G009: return "G009"
        case .G010: return "G010"
        case .G011: return "G011"
        case .G012: return "G012"
        case .G013: return "G013"
        case .G016: return "G016"
        case .G014: return "G014"
        case .G015: return "G015"
        }
    }
}
