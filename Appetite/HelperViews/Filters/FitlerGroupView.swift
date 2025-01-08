//
//  FitlerGroupView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/7/25.
//

import Foundation
import SwiftUI

struct FilterGroupView<T: FilterItemProtocol>: View {
    @EnvironmentObject var filterManager:FilterManager
    let title: String
    let items: [T]
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 250), spacing: 8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(items, id: \.code) { item in
                    Button {
                        handleFilterButtonPressed(for:item)
                    }label: {
                        Text(item.name)
                            .font(.caption2)
                            .padding()
                            .background(isSelected(item) ? .systemBlack : .systemWhite)
                            .foregroundStyle(isSelected(item) ? .systemWhite : .systemBlack)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.systemBlack, lineWidth: isSelected(item) ? 0 : 1)
                            )
                    }
                }
            }
        }
    }
}

extension FilterGroupView{
    private func isSelected(_ item:T)->Bool{
        switch T.filterType{
        case .budget:
            return filterManager.selectedBudgetFilterModels.contains(item as! BudgetFilterModel)
        case .genre:
            return filterManager.selectedGenres.contains(item as! Genre)
        case .specialCategory:
            return filterManager.selectedSpecialCategory.contains(item as! SpecialCategory)
        case .specialCategory2:
            return filterManager.selectedSpecialCategory2.contains(item as! SpecialCategory2)
        }
    }
    
    private func handleFilterButtonPressed<Y: FilterItemProtocol>(for item: Y) {
        switch Y.filterType {
        case .budget:
            toggleSelection(for: item as? BudgetFilterModel, in: &filterManager.selectedBudgetFilterModels)
        case .genre:
            toggleSelection(for: item as? Genre, in: &filterManager.selectedGenres)
        case .specialCategory:
            toggleSelection(for: item as? SpecialCategory, in: &filterManager.selectedSpecialCategory)
        case .specialCategory2:
            toggleSelection(for: item as? SpecialCategory2, in: &filterManager.selectedSpecialCategory2)
        }
    }

    private func toggleSelection<Y: Equatable>(for item: Y?, in list: inout [Y]) {
        guard let item = item else { return }
        if let index = list.firstIndex(of: item) {
            list.remove(at: index)
        } else {
            list.append(item)
        }
    }
}
