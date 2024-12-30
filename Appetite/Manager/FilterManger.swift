//
//  FilterManger.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

import Foundation
import Combine

final class FilterManger:ObservableObject{
    @Published var selectedGenres:[Genres] = []
    @Published var selectedBudgets:[Budgets] = []
    
    //toggle this when the filters is added or remove,using in onChanged()
    @Published private(set) var filterChangedFlag:Bool = false
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        setFilterChangeListener()
    }
    
    private func setFilterChangeListener(){
        Publishers.CombineLatest($selectedGenres, $selectedBudgets)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)//API　CALL　を減らすため０.５秒待たせる
            .map{genres,budgets in
                !genres.isEmpty || !budgets.isEmpty
            }
            .sink { [weak self] isChanged in
                self?.filterChangedFlag = !(self?.filterChangedFlag ?? true)
                print("FILTER: \(isChanged)")
            }
            .store(in: &cancellables)
    }
}
