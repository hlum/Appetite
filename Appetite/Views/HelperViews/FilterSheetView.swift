//
//  FilterSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/29/24.
//

import SwiftUI

struct FilterSheetView: View {
    @EnvironmentObject var filterManager:FilterManger
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    FilterSheetView()
        .environmentObject(FilterManger())
}
