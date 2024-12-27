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
    
    func moveCamera(to coordinate:CLLocationCoordinate2D,delta:Double = 0.01){
        let span = MKCoordinateSpan(
            latitudeDelta: delta,
            longitudeDelta: delta
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
    @State var selectedRestaurant:Shop? = nil
    @State var showNearbyRestaurantSheet:Bool = true
    @State var showMapStyleMenu:Bool = false
    @AppStorage("mapStyle") var mapStyle:MapStyleCases = .hybrid
    @State var showSearchView:Bool = false
    @StateObject var vm:MapViewModel = MapViewModel()
    var body: some View {
        ZStack{
            Map(position:$vm.cameraPosition){
                UserAnnotation(anchor: .center)
                
                ForEach(vm.nearbyRestaurants) { restaurant in
                    restaurantAnnotations(restaurant: restaurant)
                }
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
            .onChange(of: selectedRestaurant) { _, newValue in
                showNearbyRestaurantSheet = newValue == nil
            }
            VStack{
                Spacer()
                ForEach(vm.nearbyRestaurants) { restaurant in
                    if let selectedRestaurant = selectedRestaurant{
                        if restaurant == selectedRestaurant{
                            RestaurantPreviewView(restaurant: selectedRestaurant)
                                .shadow(color: Color.black.opacity(0.6), radius: 20)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)))
                        }
                    }
                }
            }
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
    
    private func restaurantAnnotations(restaurant:Shop) -> Annotation<Text, some View>{
        let coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.lon)
        
        return Annotation("",coordinate: coordinate){
            annotationContentView(restaurant: restaurant)
                .onTapGesture {
                    withAnimation(.bouncy) {
                        //すでに選択されているなら外す
                        if selectedRestaurant == restaurant{
                            selectedRestaurant = nil
                        }else{
                            selectedRestaurant = restaurant
                        }
                    }
                }
        }
    }

    private func annotationContentView(restaurant:Shop) -> some View{
        let isSelected = restaurant == selectedRestaurant
        return VStack(spacing:0){
            restaurant.genre.image
                .resizable()
                .scaledToFit()
                .frame(
                    width:isSelected ? 30 : 20,
                    height:isSelected ? 30 : 20
                )
                .foregroundColor(.white)
                .padding(4)
                .background(isSelected ? .red :  .orange)
                .cornerRadius(36)
                .animation(.bouncy, value: isSelected)

            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(isSelected ? .red :  .orange)
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y:isSelected ? -5 : -3)
                .animation(.bouncy, value: isSelected)
        }
        .shadow(color: isSelected ? .red.opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
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


