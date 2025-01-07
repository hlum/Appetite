//
//  FilterSection.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/29/24.
//

import SwiftUI

struct FilterSection<T:FilterItemProtocol>:View{
    let title:String
    let items:[T]
    @EnvironmentObject var filterManager:FilterManager
    let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 130), spacing: 10)
    ]
    var body:some View{
        Section{
            ScrollView(.horizontal,showsIndicators: false) {
                LazyHStack{
                    ForEach(items, id: \.self) { item in
                        Button {
                            handleFilterButtonPressed(for:item)
                        }label: {
                            Text(item.name)
                                .lineLimit(1)
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
                .frame(height:60)
            }
            

        }header: {
            Text(title)
                .font(.title2)
                .foregroundStyle(Color.systemBlack)
                .frame(maxWidth: .infinity,alignment:.leading)
        }
    }
}

extension FilterSection{
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

#Preview {
    FilterSheetView()
        .environmentObject(FilterManager())
}
