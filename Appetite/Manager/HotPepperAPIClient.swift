//
//  APICaller.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import Foundation
// 使用する検索条件
/**
 keyword
 lat
 lon
 range
 genre
 budget
 */

class HotPepperAPIClient: ObservableObject {
    private let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    private let apiKey: String
    private let maxResultsPerPage = 100
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// ホットペッパーグルメサーチAPIを使用して、指定された最大件数まで検索結果を取得します。
    ///
    /// - Parameters:
    ///   - keyword: 検索キーワード
    ///   - lat: 緯度
    ///   - lon: 経度
    ///   - range: 検索範囲
    ///   - genres: ジャンルコード配列
    ///   - budgets: 予算コード配列
    ///   - maxResults: 取得する最大件数 (nilの場合は全件取得)
    ///   - completion: 検索結果を含むレスポンス
    ///
    func searchAllShops(
        keyword: String? = nil,
        lat: Double? = nil,
        lon: Double? = nil,
        range: Int? = nil,
        genres: [Genres] = [],
        budgets: [Budgets] = [],
        maxResults: Int = 100,
        completion: @escaping (Result<HotPepperResponse, Error>) -> Void
    ) {
        // First, get total available results count
        searchShops(
            keyword: keyword,
            lat: lat,
            lon: lon,
            range: range,
            genres: genres,
            budgets: budgets,
            start: 1,
            count: 1
        ) { result in
//            guard let self = self else{
//                print("lose the object")
//                return
//            }
            switch result {
            case .success(let initialResponse):
                var totalResults = initialResponse.results.resultsAvailable ?? 0
                
                // If maxResults is less than available results, use that instead
                totalResults = min(totalResults, maxResults)
                
                
                self.fetchAllPages(
                    totalResults: totalResults,
                    keyword: keyword,
                    lat: lat,
                    lon: lon,
                    range: range,
                    genres: genres,
                    budgets: budgets,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func fetchAllPages(
        totalResults: Int,
        keyword: String?,
        lat: Double?,
        lon: Double?,
        range: Int?,
        genres: [Genres],
        budgets: [Budgets],
        completion: @escaping (Result<HotPepperResponse, Error>) -> Void
    ) {
        let numberOfPages = Int(ceil(Double(totalResults) / Double(maxResultsPerPage)))
        var allShops: [Shop] = []
        var completedRequests = 0
        var hasError = false
        
        for page in 0..<numberOfPages {
            let start = page * maxResultsPerPage + 1
            let remainingResults = totalResults - (page * maxResultsPerPage)
            let countForThisPage = min(maxResultsPerPage, remainingResults)
            
            searchShops(
                keyword: keyword,
                lat: lat,
                lon: lon,
                range: range,
                genres: genres,
                budgets: budgets,
                start: start,
                count: countForThisPage
            ) { result in
                switch result {
                case .success(let response):
                    allShops.append(contentsOf: response.results.shops)
                case .failure(let error):
                    hasError = true
                    completion(.failure(error))
                    return
                }
                
                completedRequests += 1
                
                if completedRequests == numberOfPages && !hasError {
                    // Create final response with all shops
                    let finalResponse = HotPepperResponse(results: Results(
                        apiVersion: "1.26",
                        resultsAvailable: totalResults,
                        resultsReturned: String(allShops.count),
                        resultsStart: 1,
                        shops: allShops
                    ))
                    completion(.success(finalResponse))
                }
            }
        }
    }
    
    /// Internal search function with start parameter
    private func searchShops(
        keyword: String? = nil,
        lat: Double? = nil,
        lon: Double? = nil,
        range: Int? = nil,
        genres: [Genres] = [],
        budgets: [Budgets] = [],
        start: Int,
        count: Int,
        completion: @escaping (Result<HotPepperResponse, Error>) -> Void
    ) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(CustomErrors.InvalidURL))
            return
        }
        
        var queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "start", value: String(start)),
            URLQueryItem(name: "count", value: String(count))
        ]
        
        if let keyword = keyword {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }
        
        if let lat = lat {
            queryItems.append(URLQueryItem(name: "lat", value: String(lat)))
        }
        
        if let lon = lon {
            queryItems.append(URLQueryItem(name: "lng", value: String(lon)))
        }
        
        if let range = range {
            queryItems.append(URLQueryItem(name: "range", value: String(range)))
        }
        
        if !genres.isEmpty {
            for genre in genres {
                queryItems.append(URLQueryItem(name: "genre", value: genre.code))
            }
        }
        
        if !budgets.isEmpty {
            for budget in budgets {
                queryItems.append(URLQueryItem(name: "budget", value: budget.code))
            }
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(CustomErrors.InvalidURL))
            return
        }
        print(url)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(CustomErrors.NoDataFound))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(HotPepperResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
