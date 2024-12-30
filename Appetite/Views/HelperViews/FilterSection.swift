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
    @EnvironmentObject var filterManager:FilterManger
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
                            Text(item.rawValue)
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
            return filterManager.selectedBudgets.contains(item as! Budgets)
        case .genre:
            return filterManager.selectedGenres.contains(item as! Genres)
        }
    }
    
    private func handleFilterButtonPressed(for item:T){
        switch T.filterType {
        case .budget:
            if let budgetItem = item as? Budgets {
                if !isSelected(item) {
                    filterManager.selectedBudgets.append(budgetItem)
                } else {
                    if let index = filterManager.selectedBudgets.firstIndex(of: budgetItem) {
                        filterManager.selectedBudgets.remove(at: index)
                    }
                }
            }
        case .genre:
            if let genreItem = item as? Genres {
                if !isSelected(item) {
                    filterManager.selectedGenres.append(genreItem)
                } else {
                    if let index = filterManager.selectedGenres.firstIndex(of: genreItem) {
                        filterManager.selectedGenres.remove(at: index)
                    }
                }
            }
        }
    }
}

#Preview {
    FilterSheetView()
        .environmentObject(FilterManger())
}
