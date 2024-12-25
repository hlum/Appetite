//
//  MapView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import SwiftUI
import MapKit

final class MapViewModel:ObservableObject{
    let locationManger = LocationManager()
    @Published var showLocationPermissionAlert:Bool = false
    @Published var cameraPosition:MapCameraPosition = .automatic
    @Published var userLocation:CLLocation?
    
    init(){
        getUserLocation()
    }
    
    func getUserLocation(){
        locationManger.onLocationUpdate = {[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let userLocationResult):
                    self?.userLocation = userLocationResult
                case .failure(_):
                    print("Got faliure")
                    self?.showLocationPermissionAlert = true
                }
            }
        }
    }
    
}

struct MapView: View {
    @StateObject var vm:MapViewModel = MapViewModel()
    var body: some View {
        Map(position:$vm.cameraPosition){
            UserAnnotation(anchor: .center)
        }
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
