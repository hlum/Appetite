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
//MapStyleはEquatableじゃないから判定できるようにカスタムで作る
enum MapStyleCases:Int{
    case hybrid = 1
    case standard = 2
    
    var label:String{
        switch self{
        case .hybrid:
            "航空写真"
        case .standard:
            "標準"
        }
    }
}

struct MapView: View {
    @State var showMapStyleMenu:Bool = false
    @AppStorage("mapStyle") var mapStyle:MapStyleCases = .hybrid
    @State var showSearchView:Bool = false
    @StateObject var vm:MapViewModel = MapViewModel()
    var body: some View {
        ZStack{
            Map(position:$vm.cameraPosition){
                UserAnnotation(anchor: .center)
            }
            .mapStyle(mapStyle == .hybrid ? .hybrid : .standard)
        }
        .overlay(alignment: .topLeading, content: {
            ToolBar
        })
        .alert(isPresented: $vm.showLocationPermissionAlert) {
            LocationPermissionAlert()
        }
    }
}
// MARK: UIComponents
extension MapView{
    private var ToolBar:some View{
        VStack{
            userLocationButton
            mapStyleMenuView
            Spacer()
            
        }
    }
    private var userLocationButton:some View{
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
    }
    
    
    private var mapStyleMenuView:some View{
        Menu {
            menuItemBtn(for: .standard)
            menuItemBtn(for: .hybrid)
        } label: {
            mapStyleMenuButton
        }
    }
    
    private func menuItemBtn(for style:MapStyleCases)->some View{
        Button {
            mapStyle = style
        } label: {
            HStack {
                Text(style.label)
                if style == mapStyle {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }

    }

    private var mapStyleMenuButton:some View{
        Button {
            showMapStyleMenu = true
        } label: {
            VStack{
                Image(systemName: "map.fill")
                    .font(.system(size: 20))
                    .padding()
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                
                Text("Map Style")
                    .font(.caption)
                    .foregroundStyle(.black)
            }
            .padding(.leading,30)
            .shadow(radius: 10)
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
