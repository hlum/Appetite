//
//  PerplexityAPIManager.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/4/25.
//
//docs
// https://docs.perplexity.ai/guides/getting-started

import Foundation

final class PerplexityAPIManager{
    //MODELS
    /*
     Model                             Parameter Count    Context Length    Model Type
    llama-3.1-sonar-small-128k-online    8B                     127,072    Chat Completion
    llama-3.1-sonar-large-128k-online    70B                    127,072    Chat Completion
    llama-3.1-sonar-huge-128k-online     405B                   127,072    Chat Completion
     */
    private let model = "llama-3.1-sonar-small-128k-online"
    private let temperature = 0.1 //判断力(デフォルト：０.２）0~2 （小さい方が判断力いい）
    
    static let shared = PerplexityAPIManager()
    
    func makeRequest(for data:RequestModel)async throws ->PerplexityResponseModel{
        guard let url = URL(string: "https://api.perplexity.ai/chat/completions")else{
            throw CustomErrors.InvalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIKEY.perplexityApiKey.rawValue)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": "あなたはレストランの評価を専門に行うレビュアーです。"
            ],
            [
                "role": "user",
                "content": "\(data.restaurantAdress)にある、\(data.restaurantName)という\(data.restaurantGenre)レストランのレビューをお願いします。具体的な感想や評価ポイントを教えてください。"
            ]
        ]

        
        let requestBody:[String:Any] = [
            "model": model,
            "messages":messages,
            "temperature":0.1
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data,response) = try await URLSession.shared.data(for: request)
        

        //レスポンスをチェックする
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200{
            throw URLError(.badServerResponse)
        }
        
        //JSON Decode
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let perplexityResponse = try JSONDecoder().decode(PerplexityResponseModel.self, from: data)
        
        return perplexityResponse
    }
}
