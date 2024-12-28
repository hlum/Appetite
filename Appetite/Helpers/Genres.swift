//
//  Genres.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

import Foundation

enum Genres: String,CaseIterable {
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
        return self.rawValue
    }
}
