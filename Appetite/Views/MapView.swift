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
    @Published var nearbyRestaurants:[Shop] = []
    @Published var showLocationPermissionAlert:Bool = false
    @Published var cameraPosition:MapCameraPosition = .automatic
    @Published var userLocation:CLLocationCoordinate2D?
    
    init(){
        getUserLocationAndNearbyRestaurants()
    }
        
    func getUserLocationAndNearbyRestaurants(){
        locationManger.onLocationUpdate = {[weak self] result in
            switch result{
            case .success(let userCoordinate):
                self?.userLocation = userCoordinate
                self?.getNearbyRestaurants(at: userCoordinate)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getNearbyRestaurants(at userCoordinate:CLLocationCoordinate2D){
        let apiCaller = HotPepperAPIClient(apiKey:"4914164be3a0653f")
        apiCaller.searchShops(lat: userCoordinate.latitude, lon: userCoordinate.longitude,range: 2) { [weak self] result in
                switch result{
                case .success(let response):
                    DispatchQueue.main.async {
                        self?.nearbyRestaurants = response.results.shops
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
    }
    
    func moveCamera(to coordinate:CLLocationCoordinate2D){
        let span = MKCoordinateSpan(
            latitudeDelta: 0.01,
            longitudeDelta: 0.01
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
    @State var searchText:String = ""
    @State var showNearbyRestaurantSheet:Bool = true
    @State var showMapStyleMenu:Bool = false
    @AppStorage("mapStyle") var mapStyle:MapStyleCases = .hybrid
    @State var showSearchView:Bool = false
    @StateObject var vm:MapViewModel = MapViewModel()
    var body: some View {
        Map(position:$vm.cameraPosition){
            UserAnnotation(anchor: .center)
        }
        .mapStyle(mapStyle == .hybrid ? .hybrid : .standard)
        .sheet(isPresented: $showNearbyRestaurantSheet, content: {
            NearbyRestaurantSheetView(nearbyRestaurants: $vm.nearbyRestaurants)
                .presentationCornerRadius(20)
                .presentationDetents([.height(150),.medium,.large])
                .presentationBackgroundInteraction(
                    .enabled(upThrough: .medium)
                )
                .interactiveDismissDisabled()
                .background(Color.clear)
        })
        .overlay(alignment: .topLeading, content: {
            ToolBar
        })
        .alert(isPresented: $vm.showLocationPermissionAlert) {
            LocationPermissionAlert()
        }
        .onAppear{
            vm.getUserLocationAndNearbyRestaurants()
        }
    }
}
// MARK: UIComponents
extension MapView{
    private var ToolBar:some View{
        VStack{
            mapStyleMenuView
                .padding(.vertical)
            userLocationButton
            Spacer()
        }
        .padding(30)
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
            }
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
