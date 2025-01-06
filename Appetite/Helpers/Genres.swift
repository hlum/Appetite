//
//  Genres.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//
//

struct GenreResponse: Codable {
    let results:GenreResults
}

struct GenreResults:Codable{
    let genres:[Genre]
    
    enum CodingKeys: String, CodingKey {
        case genres = "genre"
    }
}
