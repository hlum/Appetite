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
    @Published var selectedSpecialCategory:[SpecialCategory] = []
    @Published var selectedSpecialCategory2:[SpecialCategory2] = []
    
    //toggle this when the filters is added or remove,using in onChanged()
    @Published private(set) var filterChangedFlag:Bool = false
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        setFilterChangeListener()
    }
    
    deinit{
        cancellables.removeAll()
    }
    
    private func setFilterChangeListener(){
        Publishers.CombineLatest4($selectedGenres, $selectedBudgets,$selectedSpecialCategory,$selectedSpecialCategory2)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)//API　CALL　を減らすため０.５秒待たせる
            .map{genres,budgets,specialCategory,specialCategory2 in
                !genres.isEmpty || !budgets.isEmpty || !specialCategory.isEmpty || !specialCategory2.isEmpty
            }
            .sink { [weak self] isChanged in
                self?.filterChangedFlag = !(self?.filterChangedFlag ?? true)
            }
            .store(in: &cancellables)
    }
}
