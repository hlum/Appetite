//
//  APICaller.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import Foundation

enum SearchProgress{
    case completed(HotPepperResponse)
    case inProgress
    case error(Error)
}

class HotPepperAPIClient: ObservableObject {
    private let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    private let apiKey: String
    private let maxResultsPerPage = 100
    
    private var totalRequests: Int = 0
    private var completedRequests: Int = 0
    
    
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
    ///   - maxResults: 取得する最大件数 (デフォルト：１００)
    ///   - completion: 検索結果を含むレスポンス
    ///
    func searchAllShops(
        keyword: String? = nil,
        lat: Double? = nil,
        lon: Double? = nil,
        range: Int? = nil,
        genres: [Genre] = [],
        budgets: [BudgetFilterModel] = [],
        specialCategories:[SpecialCategory] = [],
        specialCategories2:[SpecialCategory2] = [],
        maxResults: Int = 100,
        completion: @escaping (SearchProgress) -> Void
    ) {
        completion(.inProgress)
        
        //デフォルトで１００個まで検索したい場合
        guard maxResults > 100 else{
            searchShops(
                keyword: keyword,
                lat: lat,
                lon: lon,
                range: range,
                genres: genres,
                budgets: budgets,
                specialCategories: specialCategories,
                specialCategories2:specialCategories2,
                start: 1,
                count: 100,
                completion: completion
            )
            return
        }
        //100個以上検索したい場合
        //何個まで取得できるかを試す
        searchShops(
            keyword: keyword,
            lat: lat,
            lon: lon,
            range: range,
            genres: genres,
            budgets: budgets,
            specialCategories: specialCategories,
            specialCategories2:specialCategories2,
            start: 1,
            count: 1
        ) {[weak self] result in
            guard let self = self else{
                return
            }
            switch result {
            case .completed(let initialResponse):
                var totalResults = initialResponse.results.resultsAvailable ?? 0
                
                if totalResults == 0{
                    let noResultResponse = HotPepperResponse(results: Results(
                        resultsAvailable: 0,
                        resultsReturned: "0",
                        resultsStart: 1,
                        shops: []
                    ))
                    completion(.completed(noResultResponse))
                }
                // 取得可能な数　と　取得したい数　から小さい方をとる
                totalResults = min(totalResults, maxResults)
                
                
                self.fetchAllPages(
                    totalResults: totalResults,
                    keyword: keyword,
                    lat: lat,
                    lon: lon,
                    range: range,
                    genres: genres,
                    budgets: budgets,
                    specialCategories: specialCategories,
                    specialCategories2: specialCategories2,
                    completion: completion
                )
            case .error(let error):
                completion(.error(error))
            case .inProgress:
                completion(.inProgress)
            }
        }
    }
    
    private func fetchAllPages(
        totalResults: Int,
        keyword: String?,
        lat: Double?,
        lon: Double?,
        range: Int?,
        genres: [Genre],
        budgets: [BudgetFilterModel],
        specialCategories: [SpecialCategory],
        specialCategories2: [SpecialCategory2],
        completion: @escaping (SearchProgress) -> Void
    ) {
        let numberOfPages = Int(ceil(Double(totalResults) / Double(maxResultsPerPage)))
        var allShops: [Shop] = []
        completedRequests = 0
        totalRequests = numberOfPages
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
                specialCategories: specialCategories,
                specialCategories2: specialCategories2,
                start: start,
                count: countForThisPage
            ) {[weak self] result in
                guard let self = self else {return}
                switch result {
                case .completed(let response):
                    allShops.append(contentsOf: response.results.shops)
                    self.completedRequests += 1
                    
                    if self.completedRequests == numberOfPages && !hasError {
                        let finalResponse = HotPepperResponse(results: Results(
                            resultsAvailable: totalResults,
                            resultsReturned: String(allShops.count),
                            resultsStart: 1,
                            shops: allShops
                        ))
                        completion(.completed(finalResponse))
                    }
                case .error(let error):
                    hasError = true
                    completion(.error(error))
                case .inProgress:
                    completion(.inProgress)
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
        genres: [Genre],
        budgets: [BudgetFilterModel],
        specialCategories: [SpecialCategory],
        specialCategories2: [SpecialCategory2],
        start: Int,
        count: Int,
        completion: @escaping (SearchProgress) -> Void
    ) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.error(CustomErrors.InvalidURL))
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
        for genre in genres {
            queryItems.append(URLQueryItem(name: "genre", value: genre.code))
        }
        for budget in budgets {
            queryItems.append(URLQueryItem(name: "budget", value: budget.code))
        }
        for specialCategory in specialCategories {
            queryItems.append(URLQueryItem(name: "special", value: specialCategory.code))
        }
        for specialCategory2 in specialCategories2 {
            queryItems.append(URLQueryItem(name: "special_category", value: specialCategory2.code))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return
        }
        
        print("DEBUG url: \(url)")
        
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, response, error in
            if let error = error {
                completion(.error(error))
                return
            }
            
            guard let data = data else {
                completion(.error(CustomErrors.NoDataFound))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(HotPepperResponse.self, from: data)
                completion(.completed(response))
            } catch {
                print("Decode error: \(error)")
                completion(.error(error))
            }
        }
        task.resume()
    }
    
}
