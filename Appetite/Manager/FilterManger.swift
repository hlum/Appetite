//
//  FilterManger.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/28/24.
//

import Foundation

final class FilterManger:ObservableObject{
    @Published var selectedGenres:[Genres] = []
    @Published var selectedBudgets:[Budgets] = []
}
