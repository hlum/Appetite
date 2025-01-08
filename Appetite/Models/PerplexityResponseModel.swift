//
//  PerplexityResponseModel.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/4/25.
//

import Foundation

struct PerplexityResponseModel: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}
struct Message: Codable {
    let content: String
}





