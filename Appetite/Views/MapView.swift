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
    @Published var currentSeeingRegion:CLLocationCoordinate2D?
    
    @Published var fetchedFirstTime:Bool = false
    
    init(){
        getUserLocationAndNearbyRestaurants()
    }
        
    func getUserLocationAndNearbyRestaurants(){
        locationManger.onLocationUpdate = {[weak self] result in
            guard let self = self else{return}
            switch result{
            case .success(let userCoordinate):
                self.userLocation = userCoordinate
                if !self.fetchedFirstTime{ //画面が表示した一回目だけ
                    self.getNearbyRestaurants(at: userCoordinate,count: 40)
                    fetchedFirstTime = true
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getNearbyRestaurants(at userCoordinate:CLLocationCoordinate2D,count:Int = 10){
        let apiCaller = HotPepperAPIClient(apiKey:"4914164be3a0653f")
        apiCaller.searchShops(lat: userCoordinate.latitude, lon: userCoordinate.longitude,range: 5,count: count) { [weak self] result in
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

//MARK: MapView body
struct MapView: View {
    @StateObject var filterManager = FilterManger()
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
            .onMapCameraChange(frequency: .onEnd, { context in
                vm.currentSeeingRegion = context.camera.centerCoordinate//get the coordinate of the region dragged by user
            })
            .mapStyle(mapStyle == .hybrid ? .hybrid : .standard)
            .sheet(isPresented: $showNearbyRestaurantSheet, content: {
                NearbyRestaurantSheetView(nearbyRestaurants: $vm.nearbyRestaurants,cameraPosition:$vm.currentSeeingRegion)
                        .presentationCornerRadius(20)
                        .presentationDetents([.height(150),.medium,.large])
                        .presentationBackgroundInteraction(
                            .enabled(upThrough: .medium)
                        )
                        .interactiveDismissDisabled()
                        .background(.systemWhite)
            })
            .overlay(alignment: .bottomTrailing, content: {
                ToolBar
                    .padding(.bottom,150)
            })

            .overlay(alignment: .top) {
                searchBarAndFilters
            }

            .alert(isPresented: $vm.showLocationPermissionAlert) {
                LocationPermissionAlert()
            }
            .onAppear{
                vm.getUserLocationAndNearbyRestaurants()
            }
            .onChange(of: selectedRestaurant) { _, newValue in
                showNearbyRestaurantSheet = newValue == nil
            }
            .background(.red)
            previewsStack
        }
    }
}
// MARK: UIComponents
extension MapView{
    private var previewsStack:some View{
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
    private var searchBarAndFilters:some View{
        ZStack{
            VStack{
                TextField("検索。。。", text: $searchText)
                    .overlay(alignment: .trailing) {
                        if !searchText.isEmpty{
                            Button {
                                searchText = ""
                            }label:{
                                Image(systemName:"xmark.circle")
                                    .font(.system(size: 25))
                                    .foregroundStyle(Color.systemBlack)
                            }
                        }
                    }
                    .padding()
                    .background(Color.systemWhite)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
                genresFilter
                budgetFilters
                
            }
            .padding(.horizontal)
        }
    }
    
    private var genresFilter:some View{
        ScrollView(.horizontal,showsIndicators: false) {
            LazyHStack{
                ForEach(Genres.allCases,id:\.self) { genre in
                    let filterSelected = filterManager.selectedGenres.contains(genre)
                    Button{
                        if !filterSelected{
                            filterManager.selectedGenres.append(genre)
                        }else{
                            if let index = filterManager.selectedGenres.firstIndex(of: genre){
                                filterManager.selectedGenres.remove(at: index)
                            }
                        }
                    }label:{
                        Text(genre.name)
                            .font(.caption)
                            .padding(7)
                            .background(filterSelected ? .systemBlack : .systemWhite)
                            .foregroundStyle(filterSelected ? .systemWhite : .systemBlack)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
            }
            .frame(height:43)
        }
    }
    
    private var budgetFilters:some View{
        ScrollView(.horizontal,showsIndicators: false) {
            LazyHStack{
                ForEach(Budgets.allCases,id:\.self) { budget in
                    let filterSelected = filterManager.selectedBudgets.contains(budget)
                    Button{
                        if !filterSelected{
                            filterManager.selectedBudgets.append(budget)
                        }else{
                            if let index = filterManager.selectedBudgets.firstIndex(of: budget){
                                filterManager.selectedBudgets.remove(at: index)
                            }
                        }
                    }label:{
                        Text(budget.rawValue)
                            .padding(7)
                            .font(.caption)
                            .background(filterSelected ? .systemBlack : .systemWhite)
                            .foregroundStyle(filterSelected ? .systemWhite : .systemBlack)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
            }
            .frame(height:40)
        }
    
    }
    
    private var ToolBar:some View{
        VStack{
            mapStyleMenuView
                .padding(.vertical)
            userLocationButton
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
                .background(.systemWhite)
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
                    .background(.systemWhite)
                    .foregroundColor(.blue)
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
#Preview {
    MapView()
        .colorScheme(.dark)
}


