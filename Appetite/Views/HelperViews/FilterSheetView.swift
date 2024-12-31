//
//  FilterSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/29/24.
//

import SwiftUI

struct FilterSheetView: View {
    @EnvironmentObject var filterManager: FilterManger
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading) {
                ScrollView {
                    if !(filterManager.selectedGenres.isEmpty && filterManager.selectedBudgets.isEmpty && filterManager.selectedSpecialCategory.isEmpty && filterManager.selectedSpecialCategory2.isEmpty){
                        selectedFiltersSection
                        RoundedRectangle(cornerRadius: 0)
                            .fill(.systemBlack.opacity(0.4))
                            .frame(height: 3)
                            .frame(maxWidth: .infinity)
                    }
                    FilterSection(title: "予算", items: Array(Budgets.allCases))
                    FilterSection(title: "ジャンル", items: Array(Genres.allCases))
                    FilterSection(title: "特集", items: Array(SpecialCategory.allCases))
                    FilterSection(title: "２。特集", items: Array(SpecialCategory2.allCases))
                }
                
               

                Spacer()
            }
            .navigationTitle("検索条件")
            .padding()
            .foregroundStyle(.systemBlack)
            .background(.systemWhite)
        }
    }
    private var selectedFiltersSection:some View{
        Section {
            VStack(alignment: .leading, spacing: 5) {
                if !filterManager.selectedGenres.isEmpty {
                    FilterGroupView(title: "ジャンル", items: filterManager.selectedGenres)
                }
                
                if !filterManager.selectedBudgets.isEmpty {
                    FilterGroupView(title: "予算", items: filterManager.selectedBudgets)
                }
                
                if !filterManager.selectedSpecialCategory.isEmpty {
                    FilterGroupView(title: "特別カテゴリー", items: filterManager.selectedSpecialCategory)
                }
                
                if !filterManager.selectedSpecialCategory2.isEmpty {
                    FilterGroupView(title: "特別カテゴリー2", items: filterManager.selectedSpecialCategory2)
                }
            }
        } header: {
            Text("選択されている条件")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity,alignment: .leading)
        }

    }
}


struct FilterGroupView<T: FilterItemProtocol>: View {
    @EnvironmentObject var filterManager:FilterManger
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
                ForEach(items, id: \.rawValue) { item in
                    Button {
                        handleFilterButtonPressed(for:item)
                    }label: {
                        Text(item.rawValue)
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
            return filterManager.selectedBudgets.contains(item as! Budgets)
        case .genre:
            return filterManager.selectedGenres.contains(item as! Genres)
        case .specialCategory:
            return filterManager.selectedSpecialCategory.contains(item as! SpecialCategory)
        case .specialCategory2:
            return filterManager.selectedSpecialCategory2.contains(item as! SpecialCategory2)
        }
    }
    
    private func handleFilterButtonPressed<Y: FilterItemProtocol>(for item: Y) {
        switch Y.filterType {
        case .budget:
            toggleSelection(for: item as? Budgets, in: &filterManager.selectedBudgets)
        case .genre:
            toggleSelection(for: item as? Genres, in: &filterManager.selectedGenres)
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
        .environmentObject(FilterManger())
        .colorScheme(.light)
}
