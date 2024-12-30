//
//  MapView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import SwiftUI
import MapKit

//MARK: MapView body
struct MapView: View {
    @State var cameraPositionChanged = false
    @EnvironmentObject var filterManager:FilterManger
    @State var showMapStyleMenu:Bool = false
    @AppStorage("mapStyle") var mapStyle:MapStyleCases = .hybrid
    //temp,onAppearでfilterManagerを渡す
    @StateObject var vm:MapViewModel = MapViewModel(filterManager:nil)
    
    var body: some View {
        ZStack{
            Map(position:$vm.cameraPosition){
                UserAnnotation(anchor: .center)
                ForEach(vm.showSearchedRestaurants ? vm.searchedRestaurants : vm.nearbyRestaurants) { restaurant in
                    restaurantAnnotations(restaurant: restaurant)
                }
            }
            .onMapCameraChange(frequency: .onEnd, { context in
                withAnimation(.bouncy) {
                    cameraPositionChanged = true
                }
                vm.currentSeeingRegionSpan = context.region.span
                vm.currentSeeingRegionCenterCoordinate = context.camera.centerCoordinate//get the coordinate of the region dragged by user
            })
            .mapStyle(mapStyle == .hybrid ? .hybrid : .standard)
            .sheet(
                isPresented: $vm.showNearbyRestaurantSheet,
                content: {
                    NearbyRestaurantSheetView(
                        nearbyRestaurants: vm.showSearchedRestaurants ? $vm.searchedRestaurants : $vm.nearbyRestaurants,
                        cameraPosition: $vm.currentSeeingRegionCenterCoordinate,
                        selectedRestaurant:$vm.selectedRestaurant
                    )
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(20)
                    .presentationDetents([.height(150),.medium,.large])
                    .background(.systemWhite)
                })
            .sheet(isPresented: $vm.showFilterSheet, content: {
                FilterSheetView()
                    .environmentObject(filterManager)
                    .presentationDetents([.medium,.large])
            })
            .overlay(alignment: .bottomTrailing, content: {
                ToolBar
                    .padding(.bottom,150)
            })

            .overlay(alignment: .top) {
                VStack{
                    searchBarAndFilters
                    if cameraPositionChanged{
                        searchThisAreaButton
                    }
                }
            }

            .alert(isPresented: $vm.showLocationPermissionAlert) {
                LocationPermissionAlert()
            }
            .onAppear{
                vm.getUserLocationAndNearbyRestaurants()
                vm.setUp(filterManager)
            }
            .onChange(of: vm.selectedRestaurant) { _, newValue in
                vm.showNearbyRestaurantSheet = newValue == nil && !vm.showFilterSheet
                if let lon = newValue?.lon,
                   let lat = newValue?.lat{
                    vm.moveCamera(to: CLLocationCoordinate2D(latitude: lat, longitude:lon))
                }
            }
            .onChange(of:vm.showFilterSheet) { _, newValue in
                vm.showNearbyRestaurantSheet = !newValue && vm.selectedRestaurant == nil
            }
            .onChange(of: filterManager.filterChangedFlag) { _, _ in
                handleFilterChanges()
            }
            previewsStack
        }
    }
}
// MARK: UIComponents
extension MapView{
    private var searchThisAreaButton:some View{
        VStack{
            Button{
                withAnimation(.bouncy){
/*
 showSearchedRestaurants はフィルターとsearchTextがなくなる時falseになって
 nearbyRestaurantだけが表示されるから
 "このエリアを検索"　ボタンを押された時には
 フィルターやsearchTextがなくても見ている範囲内のレストランを出すため
 */
                    vm.searchSeeingArea = true
                    
                    vm.selectedRestaurant = nil
                    
                    vm
                        .searchRestaurantsWithSelectedFilters(
                            keyword:vm.searchText,
                            budgets: filterManager.selectedBudgets,
                            genres: filterManager.selectedGenres,
                            selectedSpecialCategories: filterManager.selectedSpecialCategory,
                            selectedSpecialCategory2: filterManager.selectedSpecialCategory2
                        )
                    cameraPositionChanged = false
                }
            }label:{
                Text("このエリアを検索")
                    .font(.caption)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(30)
                    .shadow(radius: 3)
                    .foregroundStyle(Color.white)
            }
        }
        .frame(maxHeight:.infinity,alignment:.top)
        .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top)))
    }
    
    private var previewsStack:some View{
        VStack{
            Spacer()
            ForEach(vm.showSearchedRestaurants ? vm.searchedRestaurants : vm.nearbyRestaurants) { restaurant in
                if let selectedRestaurant = vm.selectedRestaurant{
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
                HStack{
                    showFilterSheetButton
                    searchBar
                }
                genresFilter
                budgetFilters
                
            }
            .padding()
        }
    }
    
    private var searchBar:some View{
        TextField("検索。。。", text: $vm.searchText)
            .textInputAutocapitalization(.never)
            .overlay(alignment: .trailing) {
                if !vm.searchText.isEmpty{
                    Button {
                        vm.searchText = ""
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
    }
    
    private var showFilterSheetButton:some View{
        Button{
            vm.showFilterSheet = true
        }label: {
            Image(systemName: "slider.horizontal.3")
                .font(.title3)
                .padding()
                .background(.systemWhite)
                .cornerRadius(15)
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
                        if vm.selectedRestaurant == restaurant{
                            vm.selectedRestaurant = nil
                        }else{
                            vm.selectedRestaurant = restaurant
                        }
                    }
                }
        }
    }

    private func annotationContentView(restaurant:Shop) -> some View{
        let isSelected = restaurant == vm.selectedRestaurant
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

extension MapView{
    private func handleFilterChanges(){
        withAnimation{
            //フィルタが一つも選択されていない時はFalse
            vm.showSearchedRestaurants = !(
                filterManager.selectedGenres.isEmpty &&
                filterManager.selectedBudgets.isEmpty &&
                filterManager.selectedSpecialCategory.isEmpty &&
                filterManager.selectedSpecialCategory2.isEmpty &&
                vm.searchText.isEmpty
            )

            print("showSearchRestaurants: \(vm.showSearchedRestaurants)")
            //もし選択されてるレストランが条件が変わってリストにない時バグが出るから外す！！
            vm.selectedRestaurant =  nil
            
            vm.searchRestaurantsWithSelectedFilters(keyword: vm.searchText,budgets: filterManager.selectedBudgets, genres: filterManager.selectedGenres, selectedSpecialCategories: filterManager.selectedSpecialCategory,selectedSpecialCategory2:filterManager.selectedSpecialCategory2)
        }
    }
}

#Preview {
    MapView()
        .environmentObject(FilterManger())

}
#Preview {
    MapView()
        .environmentObject(FilterManger())
        .colorScheme(.dark)
}


