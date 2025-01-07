//
//  FilterManger.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

import Foundation
import Combine

final class FilterManager:ObservableObject{
    @Published var selectedGenres:[Genre] = []
    @Published var selectedBudgetFilterModels:[BudgetFilterModel] = []
    @Published var selectedSpecialCategory:[SpecialCategory] = []
    @Published var selectedSpecialCategory2:[SpecialCategory2] = []
    
    var availableGenres:[Genre] = []
    var availableBudgets:[BudgetFilterModel] = []
    var availableSpecialCategories:[SpecialCategory] = []
    var availableSpecialCategories2:[SpecialCategory2] = []

    
    //toggle this when the filters is added or remove,using in onChanged()
    @Published private(set) var filterChangedFlag:Bool = false
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        setFilterChangeListener()
        fetchBudgetFilters()
        fetchGenresFilters()
        fetchSpecialCategoryFilters()
        fetchSpecialCategory2Filters()
    }
    
    
    deinit{
        cancellables.removeAll()
    }
    
    private func setFilterChangeListener(){
        Publishers.CombineLatest4($selectedGenres, $selectedBudgetFilterModels,$selectedSpecialCategory,$selectedSpecialCategory2)
            .dropFirst()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)//API　CALL　を減らすため０.５秒待たせる
            .map{genres,budgets,specialCategory,specialCategory2 in
                !genres.isEmpty || !budgets.isEmpty || !specialCategory.isEmpty || !specialCategory2.isEmpty
            }
            .sink { [weak self] isChanged in
                self?.filterChangedFlag = !(self?.filterChangedFlag ?? true)
            }
            .store(in: &cancellables)
    }

    private func fetchGenresFilters(){
        fetchData(from: "genre", responseType: GenreResponse.self) { result in
            switch result{
            case .success(let results):
                self.availableGenres = results.results.genres
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchBudgetFilters(){
        fetchData(from: "budget", responseType: BudgetResponse.self) { result in
            switch result{
            case .success(let response):
                self.availableBudgets = response.results.budgets
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchSpecialCategoryFilters(){
        fetchData(from: "special", responseType: SpecialCategoryResponse.self) { result in
            switch result{
            case .success(let response):
                self.availableSpecialCategories = response.results.specials
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchSpecialCategory2Filters(){
        fetchData(from: "special_category", responseType: SpecialCategory2Response.self) { result in
            switch result{
            case .success(let response):
                self.availableSpecialCategories2 = response.results.specialCategories
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func fetchData<T: Decodable>(from endpoint: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let baseURL = "https://webservice.recruit.co.jp/hotpepper/\(endpoint)/v1/"
        var components = URLComponents(string: baseURL)!
        
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "key", value: APIKEY.hotpepperApiKey.rawValue),
            URLQueryItem(name: "format", value: "json")
        ]
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("Invalid URL")
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch let DecodingError.dataCorrupted(context) {
                print("Data corrupted: \(context)")
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key not found: \(key), \(context)")
            } catch let DecodingError.typeMismatch(type, context) {
                print("Type mismatch: \(type), \(context)")
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value not found: \(value), \(context)")
            } catch {
                print("Unknown error: \(error)")
            }

        }
        
        task.resume()
    }

    
    
}
