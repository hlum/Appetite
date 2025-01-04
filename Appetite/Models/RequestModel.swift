//
//  RequestModel.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/4/25.
//

import Foundation

struct RequestModel{
    let restaurantName:String
    let restaurantAdress:String
    let restaurantGenre:String
    
    init(for shop:Shop){
        self.restaurantName = shop.name
        self.restaurantGenre = shop.genre.name
        self.restaurantAdress = shop.address
    }
}
