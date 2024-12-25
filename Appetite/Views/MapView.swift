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
    @Published var userLocation:CLLocationCoordinate2D?
    
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
    
    func moveCamera(to coordinate:CLLocationCoordinate2D){
        let span = MKCoordinateSpan(
            latitudeDelta: 0.001,
            longitudeDelta: 0.001
        )
        let region = MKCoordinateRegion(
            center: coordinate,
            span: span
        )
        withAnimation(.easeIn){
            cameraPosition = .region(region)
        }
        
    }
    
}

struct MapView: View {
    @StateObject var vm:MapViewModel = MapViewModel()
    var body: some View {
        ZStack{
            Map(position:$vm.cameraPosition){
                UserAnnotation(anchor: .center)
            }
            VStack{
                Spacer()
                BottomToolBar
            }
        }
        .alert(isPresented: $vm.showLocationPermissionAlert) {
            LocationPermissionAlert()
        }
    }
}
// MARK: UIComponents
extension MapView{
    private var BottomToolBar:some View{
        HStack{
            Button {
                if let userLocation = vm.userLocation{
                    vm.moveCamera(to:userLocation)
                }
            } label: {
                Image(systemName:"paperplane.fill")
                    .font(.system(size: 20))
                    .padding()
                    .background(.white)
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .padding(.leading,30)
                    .shadow(radius: 10)
            }
            Spacer()
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
