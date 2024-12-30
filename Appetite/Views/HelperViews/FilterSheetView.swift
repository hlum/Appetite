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
                        .environmentObject(filterManager)
                    FilterSection(title: "ジャンル", items: Array(Genres.allCases))
                        .environmentObject(filterManager)
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
