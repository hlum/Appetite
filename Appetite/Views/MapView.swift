//
//  MapView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import SwiftUI

struct MapView: View {
    @StateObject var vm:MapViewModel = MapViewModel()
    var body: some View {
        Map()
            .alert(isPresented: $vm.showLocationPermissionAlert) {
                LocationPermissionAlert()
            }
    }
}

//LocationAlert
extension MapView{
    private func LocationPermissionAlert()->Alert{
        Alert(title: Text("位置情報の使用が制限されています"), primaryButton: .default(Text("設定を開く"), action: {
            Appetite.LocationPermissionAlert.show()
        }), secondaryButton: .cancel())
    }
}

#Preview {
    MapView()
}
