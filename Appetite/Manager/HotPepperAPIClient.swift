//
//  APICaller.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import Foundation

enum SearchProgress{
    case progress(Double)
    case completed(HotPepperResponse)
    case error(Error)
}

class HotPepperAPIClient: ObservableObject {
    private let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    private let apiKey: String
    private let maxResultsPerPage = 100
    private var observer:NSKeyValueObservation? = nil
    
    private var currentProgress: Double = 0.0
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
        specialCategories:[SpecialCategory] = [],
        specialCategories2:[SpecialCategory2] = [],
        maxResults: Int = 100,
        completion: @escaping (SearchProgress) -> Void
    ) {
        // First, get total available results count
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
                print("lose the object")
                return
            }
            switch result {
            case .completed(let initialResponse):
                var totalResults = initialResponse.results.resultsAvailable ?? 0
                
                if totalResults == 0{
                    completion(.error(CustomErrors.NoDataFound))
                }
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
                    specialCategories: specialCategories,
                    specialCategories2: specialCategories2,
                    completion: completion
                )
            case .error(let error):
                completion(.error(error))
            case .progress(let progress):
                completion(.progress(progress))
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
        specialCategories: [SpecialCategory],
        specialCategories2: [SpecialCategory2],
        completion: @escaping (SearchProgress) -> Void
    ) {
        let numberOfPages = Int(ceil(Double(totalResults) / Double(maxResultsPerPage)))
        var allShops: [Shop] = []
        completedRequests = 0
        totalRequests = numberOfPages
        currentProgress = 0.0
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
            ) { result in
                switch result {
                case .completed(let response):
                    allShops.append(contentsOf: response.results.shops)
                    self.completedRequests += 1
                    self.updateProgress(completion: completion)
                    if self.completedRequests == numberOfPages && !hasError {
                        let finalResponse = HotPepperResponse(results: Results(
                            apiVersion: "1.26",
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
                case .progress(let progress):
                    self.currentProgress += progress / Double(self.totalRequests)
                    self.updateProgress(completion: completion)
                }
            }
        }
    }

    private func updateProgress(completion: (SearchProgress) -> Void) {
        let progress = min(currentProgress, 1.0)
        completion(.progress(progress))
    }

    
    /// Internal search function with start parameter
    private func searchShops(
        keyword: String? = nil,
        lat: Double? = nil,
        lon: Double? = nil,
        range: Int? = nil,
        genres: [Genres],
        budgets: [Budgets],
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
            completion(.error(CustomErrors.InvalidURL))
            return
        }
        
        print("DEBUG url: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
        
        self.observer = task.progress.observe(\.fractionCompleted) { progress, _ in
            if progress.fractionCompleted < 1.0 {
                completion(.progress(progress.fractionCompleted))
            }
        }
        task.resume()
        task.observe(\.state) {[weak self] task, _ in
            if task.state == .completed || task.state == .suspended || task.state == .canceling{
                self?.observer?.invalidate()
            }
        }
    }

}
