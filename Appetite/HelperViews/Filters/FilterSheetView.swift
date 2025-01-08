//
//  FilterSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/29/24.
//

import SwiftUI

struct FilterSheetView: View {
    @State var showAlert:Bool = false
    @State var alertMessage :String = ""
    @EnvironmentObject var filterManager: FilterManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(alignment: .leading) {
                    ScrollView(showsIndicators: false) {
                        filters
                        .padding(.bottom, 70) //Dismissボタンのためのスペース
                    }
                    Spacer()
                }
                .navigationTitle("検索条件")
                .padding()
                .foregroundStyle(.systemBlack)
                .background(.systemWhite)
            }
            
            closeButton
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text("全部解除しますか？"), message: Text(alertMessage),
                  primaryButton:.destructive(Text("はい"), action: deleteAllFilters),
                  secondaryButton: .cancel(Text("いいえ")) )
        }
    }
}

extension FilterSheetView{
    
    private var filters:some View{
        VStack {
            if !(filterManager.selectedGenres.isEmpty &&
                filterManager.selectedBudgetFilterModels.isEmpty &&
                filterManager.selectedSpecialCategory.isEmpty &&
                filterManager.selectedSpecialCategory2.isEmpty) {
                selectedFiltersSection
                RoundedRectangle(cornerRadius: 0)
                    .fill(.systemBlack.opacity(0.4))
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
            }
            
            FilterSection(title: "予算", items: filterManager.availableBudgets)
            FilterSection(title: "ジャンル", items: filterManager.availableGenres)
            FilterSection(title: "特集", items: filterManager.availableSpecialCategories)
            FilterSection(title: "特集(2)", items: filterManager.availableSpecialCategories2)
        }
    }
    private var closeButton:some View{
        VStack {
            Spacer()
            Button {
                dismiss.callAsFunction()
            } label: {
                Image(systemName: "x.circle")
                    .font(.system(size: 40))
                    .frame(width: 55, height: 55)
                    .background(.systemWhite)
                    .foregroundStyle(.red)
                    .cornerRadius(40)
                    .shadow(color: .red.opacity(0.7), radius: 10, y: 3)
            }
            .padding(.bottom, 20)
        }
    }
    
    private var selectedFiltersSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 5) {
                if !filterManager.selectedGenres.isEmpty {
                    FilterGroupView(title: "ジャンル", items: filterManager.selectedGenres)
                }
                
                if !filterManager.selectedBudgetFilterModels.isEmpty {
                    FilterGroupView(title: "予算", items: filterManager.selectedBudgetFilterModels)
                }
                
                if !filterManager.selectedSpecialCategory.isEmpty {
                    FilterGroupView(title: "特別カテゴリー", items: filterManager.selectedSpecialCategory)
                }
                
                if !filterManager.selectedSpecialCategory2.isEmpty {
                    FilterGroupView(title: "特別カテゴリー2", items: filterManager.selectedSpecialCategory2)
                }
            }
        } header: {
            HStack{
                Text("選択されている条件")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom,8)
                Button {
                    showAlert(for: "検索条件が全部解除されます。よろしいですか　？")
                } label: {
                    Text("全部解除")
                        .foregroundStyle(.red)
                        .cornerRadius(10)
                }
            }
        }
    }
    private func showAlert(for message:String){
        showAlert = true
        alertMessage = message
    }
    private func deleteAllFilters(){
        filterManager.selectedGenres = []
        filterManager.selectedBudgetFilterModels = []
        filterManager.selectedSpecialCategory = []
        filterManager.selectedSpecialCategory2 = []
    }
}

#Preview {
    FilterSheetView()
        .environmentObject(FilterManager())
        .colorScheme(.light)
}
