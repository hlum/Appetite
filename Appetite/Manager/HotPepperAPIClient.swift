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

class HotPepperAPIClient:ObservableObject {
    private let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// ホットペッパーグルメサーチAPIを使用して、指定された条件に基づいて飲食店を検索します。
    ///
    /// この関数は非同期で実行され、検索結果はcompletionハンドラを通じて返されます。
    /// 検索条件は全て任意パラメータとして指定可能で、複数の条件を組み合わせることができます。
    ///
    /// - Parameters:
    ///   - keyword: 検索キーワード
    ///             店名、住所、駅名、お店ジャンルなどのフリーワード検索が可能です。
    ///   - lat: 緯度
    ///         位置情報による検索を行う場合の緯度を指定します。
    ///   - lon: 経度
    ///         位置情報による検索を行う場合の経度を指定します。
    ///   - range: 検索範囲
    ///          位置情報による検索時の範囲を指定します。
    ///          1: 300m
    ///          2: 500m
    ///          3: 1000m (デフォルト)
    ///          4: 2000m
    ///          5: 3000m
    ///   - genre: お店ジャンルコード
    ///          ジャンルによる絞り込み検索を行う場合に指定します。
    ///   - budget: 予算コード
    ///           予算による絞り込み検索を行う場合に指定します。
    ///   - completion: 検索結果を受け取るコールバック
    ///               `.success(HotPepperResponse)`: 検索成功時のレスポンス
    ///               `.failure(Error)`: エラー発生時の詳細
    ///
    /// - Note:
    ///   - 位置情報検索を行う場合は、lat（緯度）とlon（経度）の両方を指定する必要があります。
    ///   - エラーの種類:
    ///     - `CustomErrors.InvalidURL`: URLの生成に失敗
    ///     - `CustomErrors.NoDataFound`: データが取得できない
    ///     - その他のネットワークエラーやデコードエラー
    ///
    func searchShops(
        keyword: String? = nil,
        lat: Double? = nil,
        lon: Double? = nil,
        range: Int? = nil,
        genres: [Genres] = [],
        budgets: [Budgets] = [],
        count: Int = 10,
        completion: @escaping (Result<HotPepperResponse, Error>) -> Void
    ) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(CustomErrors.InvalidURL))
            return
        }
        
        // Build query items array
        var queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "count", value: String(count))
        ]
        
        // Add optional parameters
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
                
            } catch let DecodingError.dataCorrupted(context) {
                print("Data corrupted:", context.debugDescription)
                print("Coding Path:", context.codingPath)
                completion(.failure(DecodingError.dataCorrupted(context)))
                
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key.stringValue)' not found:", context.debugDescription)
                print("Coding Path:", context.codingPath)
                completion(.failure(DecodingError.keyNotFound(key, context)))
                
            } catch let DecodingError.typeMismatch(type, context) {
                print("Type mismatch for type \(type):", context.debugDescription)
                print("Coding Path:", context.codingPath)
                completion(.failure(DecodingError.typeMismatch(type, context)))
                
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("Coding Path:", context.codingPath)
                completion(.failure(DecodingError.valueNotFound(value, context)))
                
            } catch {
                print("Unknown error:", error.localizedDescription)
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
