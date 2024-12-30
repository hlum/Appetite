//
//  FilterSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/29/24.
//

import SwiftUI

struct FilterSheetView: View {
    @EnvironmentObject var filterManager: FilterManger
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading) {
                ScrollView {
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
}

#Preview {
    FilterSheetView()
        .environmentObject(FilterManger())
        .colorScheme(.light)
}
