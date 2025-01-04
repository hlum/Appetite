//
//  PerplexityResponseModel.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/4/25.
//

import Foundation

struct PerplexityResponseModel: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finishReason: String?
}

struct Usage: Codable {
    let promptTokens: Int?
    let completion_tokens: Int
    let totalTokens: Int?
}

struct Message: Codable {
    let role: String
    let content: String
}





