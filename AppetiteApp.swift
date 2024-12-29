//
//  AppetiteApp.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import SwiftUI

@main
struct AppetiteApp: App {
    @StateObject var filterManager = FilterManger()
    var body: some Scene {
        WindowGroup {
                MapView()
                .environmentObject(filterManager)
        }
    }
}
