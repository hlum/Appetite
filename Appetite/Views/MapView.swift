//
//  MapView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import SwiftUI
import MapKit
import Lottie

//MARK: MapView body
struct MapView: View {
    //For Transition
    @State var swipedLeft:Bool = false
    @State var swipedDown:Bool = false
    
    @State var isDragging:Bool = false
    @AppStorage("aiButtonXOffset") var aiButtonXOffset:Double = 200
    @AppStorage("aiButtonYOffset") var aiButtonYOffset:Double = 50
    @State var previewDragOffset:CGSize = .zero
    @State var showProgressView:Bool = false
    @State var cameraPositionChanged = false
    @EnvironmentObject var filterManager:FilterManager
    @State var showMapStyleMenu:Bool = false
    @AppStorage("mapStyle") var mapStyle:MapStyleCases = .standard
    //temp,onAppearでfilterManagerを渡す
    @StateObject var vm:MapViewModel = MapViewModel(filterManager:nil)
    
    var body: some View {
        ZStack{
            if vm.selectedRoute == nil{//案内中は別のView
                   normalStateMapView
                    .transition(.fade)
            }else{
                    tripStateMapView
                    .transition(.fade)
            }
            
            if vm.showAlert{
                customAlert
            }
            
            if vm.showLocationPermissionAlert{
                locationPermissionAlert
            }
        }
        .overlay(alignment: .bottom) {
            if let _ = vm.selectedRoute{
                
                HStack{
                    tripDetailView
                    
                    Spacer()
                    cancelDestinationButton
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .bottom)
                    )
                )
                
                .frame(maxWidth: .infinity,alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding()
                .shadow(radius: 10)
                //for the transition to work
                .frame(maxHeight: .infinity,alignment:.bottom)
                
            }
            
            
        }
    }
}

//MARK: Main Components
extension MapView{
    private var normalStateMapView:some View{
        ZStack{
            Map(position:$vm.cameraPosition){
                UserAnnotation(anchor: .center)
                ForEach(vm.showSearchedRestaurants ? vm.searchedRestaurants : vm.nearbyRestaurants) { restaurant in
                    restaurantAnnotations(restaurant: restaurant)
                }
            }
            .brightness(vm.stillLoading ? -0.3 : 0.0)
    //            .brightness(-0.3)
            .onMapCameraChange(frequency: .continuous, {context in
                vm.currentSeeingRegionSpan = context.region.span
                vm.currentSeeingRegionCenterCoordinate = context.camera.centerCoordinate//get the coordinate of the region dragged by user
                vm.calculateRange(for: vm.currentSeeingRegionSpan)
            })
            .onMapCameraChange(frequency: .onEnd, { context in
                withAnimation(.bouncy) {
                    cameraPositionChanged = true
                }
                vm.currentSeeingRegionSpan = context.region.span
                vm.currentSeeingRegionCenterCoordinate = context.camera.centerCoordinate//get the coordinate of the region dragged by user
            })
            .mapStyle(mapStyle == .hybrid ? .hybrid : .standard)
                .sheet(
                isPresented: $vm.showRoutesSheet,
                content: {
                    RoutesSheetView(
                        getRoutes: vm.getAvailableRoutes,
                        selectedRestaurant: $vm.selectedRestaurant,
                        availableRoutes: $vm.availableRoutes,
                        selectedRoute: $vm.selectedRoute,
                        transportType: $vm.transportType
                    )
                    .presentationDetents([.medium])
                    .presentationBackgroundInteraction(.disabled)
                    .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $vm.showAiResultSheet, content: {
                if let selectedRestaurant = vm.selectedRestaurant{
                    let request = RequestModel(for: selectedRestaurant)
                    AIReviewSheet(request: request)
                }
            })
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
            .sheet(isPresented: $vm.showDetailSheetView, content: {
                if let selectedRestaurant = vm.selectedRestaurant{
                    DetailSheetView(shop:selectedRestaurant,showRoutesSheet: $vm.showRoutesSheet)
                }
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
            .onAppear{
                if let userLocation = vm.userLocation{
                    vm.moveCamera(to:userLocation)
                }
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

            if vm.stillLoading{
                VStack{
                    LottieView(name: "LoadingAnimation", loopMode: .loop, labelText: nil)
                        .frame(height:300)
                }
            }
            
            if vm.selectedRestaurant != nil{
                aiReviewButton
            }
        }
    }
    
    private var tripStateMapView:some View{
        ZStack{
            Map(position: $vm.cameraPosition){
                UserAnnotation(anchor: .center)
                if let selectedRestaurant = vm.selectedRestaurant{
                    restaurantAnnotations(restaurant: selectedRestaurant)
                }
                if let route = vm.selectedRoute{
                    MapPolyline(route.polyline)
                        .stroke(Color.blue, lineWidth: 4)
                }
            }
            .transition(.fade)
            .overlay(alignment: .topLeading, content: {
                ToolBar
            })
            .mapStyle(mapStyle == .hybrid ? .hybrid(elevation:.realistic,showsTraffic: true) : .standard(elevation:.realistic,showsTraffic: true))
            .onAppear{
                if let userLocation = vm.userLocation{
                    vm.moveCamera(to:userLocation)
                }
                vm.updateRoute()
            }
        }
    }
}

// MARK: UIComponents
extension MapView{
    private var aiReviewButton:some View{
        GeometryReader { geometry in
            VStack {
                Button {
                    if !isDragging{//押し間違いを防止する
                        vm.showAiResultSheet = true
                    }
                } label: {
                    VStack {
                        LottieView(
                            name: "robotAnimation.json",
                            loopMode: .loop,
                            labelText: "AI評価"
                        )
                        .frame(width: 110, height: 150)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            // ドラッグ中の新しい位置を計算
                            let newOffset = CGSize(
                                width: aiButtonXOffset + value.translation.width,
                                height: aiButtonYOffset + value.translation.height
                            )
                            
                            // 画面の範囲内での移動制限
                            let maxWidth = geometry.size.width - 100 // ボタンの幅を考慮した最大横位置
                            let maxHeight = geometry.size.height - 150 // ボタンの高さ
                            withAnimation(.spring){
                                // 画面外に出ないように値を制限
                                aiButtonXOffset = min(max(newOffset.width, 0), maxWidth)
                                aiButtonYOffset = min(max(newOffset.height, 0), maxHeight)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                // ドラッグ終了時に最終位置を保持またはリセット
                                let newOffset = CGSize(
                                    width: aiButtonXOffset + value.translation.width,
                                    height: aiButtonYOffset + value.translation.height
                                )
                                
                                // 終了時も範囲内に制限
                                let maxWidth = geometry.size.width - 100 // ボタンの幅を考慮した最大横位置
                                let maxHeight = geometry.size.height - 150 // ボタンの高さ
                                
                                withAnimation(.spring){
                                    // 画面外に出ないように値を制限
                                    aiButtonXOffset = min(max(newOffset.width, 0), maxWidth)
                                    aiButtonYOffset = min(max(newOffset.height, 0), maxHeight)
                                    //押し間違いを防止する
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isDragging = false
                                    }
                                }
                            }
                        }
                )

            }
            .offset(CGSize(width: aiButtonXOffset, height: aiButtonYOffset)) // Apply the clamped offset
        }
    }
    
    private var customAlert: some View {
        GroupBox("エラ") {
            VStack(alignment: .center, spacing: 20) {
                Text(vm.alertMessage)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                
                HStack(spacing: 16) {
                    cancelButton
                }
            }
            .frame(height: 150)
        }
        .padding(.horizontal, 50)
        .shadow(radius: 10,y:5)
    }

    private var locationPermissionAlert: some View {
        GroupBox("エラ") {
            VStack(alignment: .center, spacing: 20) {
                Text(vm.alertMessage)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                
                HStack(spacing: 16) {
                    locationSettingsButton
                    cancelButton
                }
            }
            .frame(height: 150)
        }
        .padding(.horizontal, 50)
        .shadow(radius: 10,y:5)
    }
    
    private var locationSettingsButton: some View {
        Button(action: {
            vm.showLocationPermissionAlert = false
            Appetite.LocationPermissionAlert.show()
        }) {
            Text("設定")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }

    
    private var cancelButton: some View {
        Button(action: {
            vm.showAlert = false
            vm.showLocationPermissionAlert = false
        }) {
            Text("キャンセル")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }


    
    
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
                            budgets: filterManager.selectedBudgetFilterModels,
                            genres: filterManager.selectedGenres,
                            selectedSpecialCategories: filterManager.selectedSpecialCategory,
                            selectedSpecialCategory2: filterManager.selectedSpecialCategory2
                        )
                    cameraPositionChanged = false
                }
            }label:{
                Text("この\(vm.range)m以内を検索")
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
    
    private var previewsStack: some View {
        VStack {
            Spacer()
            ForEach(vm.showSearchedRestaurants ? vm.searchedRestaurants : vm.nearbyRestaurants) { restaurant in
                if let selectedRestaurant = vm.selectedRestaurant {
                    if restaurant == selectedRestaurant {
                        RestaurantPreviewView(
                            selectedRestaurant: selectedRestaurant,
                            showDetailSheetView: $vm.showDetailSheetView,
                            showRoutesSheet: $vm.showRoutesSheet
                        )
                        .shadow(color: Color.black.opacity(0.6), radius: 20)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge:swipedLeft ? .trailing : .bottom),
                            removal: .move(edge: swipedDown ? .bottom :
                                           swipedLeft ? .bottom : .trailing)
                        ))
                        .offset(previewDragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    handleDragChange(value)
                                }
                                .onEnded { value in
                                    handleDrageEnd(value)
                                }
                        )
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
                ForEach(filterManager.availableGenres,id:\.code) { genre in
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
                ForEach(filterManager.availableBudgets,id:\.code) { budget in
                        // Check if the budget is in the selected list
                    let filterSelected = filterManager.selectedBudgetFilterModels.contains(budget)
                        Button {
                            if !filterSelected {
                                filterManager.selectedBudgetFilterModels.append(budget)
                            } else {
                                if let index = filterManager.selectedBudgetFilterModels.firstIndex(of: budget) {
                                    filterManager.selectedBudgetFilterModels.remove(at: index)
                                }
                            }
                        } label: {
                            Text(budget.name)
                                .font(.caption)
                                .padding(7)
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
//            if #available(iOS 17.3, *){ //hybrid は　IOS 17.3じゃないと使えないので
                mapStyleMenuView
                    .padding(.vertical)
//            }
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
                        //すでに選択されているなら外す //ルート案内中は外せない
                        if vm.selectedRestaurant == restaurant && vm.selectedRoute == nil{
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
                    width: isSelected ? 40 : 20,
                    height: isSelected ? 40 : 20
                )
                .foregroundColor(.black) //for the defaut systemIcon
                .padding(4)
                .background(
                       Circle()
                           .fill(Color.white)
                   )
                .cornerRadius(36)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.red : Color.orange, lineWidth: isSelected ? 5 : 2)
                )
                .padding(4)
                .animation(.bouncy, value: isSelected)

            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(isSelected ? .red : .orange)
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
                filterManager.selectedBudgetFilterModels.isEmpty &&
                filterManager.selectedSpecialCategory.isEmpty &&
                filterManager.selectedSpecialCategory2.isEmpty &&
                vm.searchText.isEmpty
            )

            print("showSearchRestaurants: \(vm.showSearchedRestaurants)")
            //もし選択されてるレストランが条件が変わってリストにない時バグが出るから外す！！
            vm.selectedRestaurant =  nil
            
            vm.searchRestaurantsWithSelectedFilters(keyword: vm.searchText,budgets: filterManager.selectedBudgetFilterModels, genres: filterManager.selectedGenres, selectedSpecialCategories: filterManager.selectedSpecialCategory,selectedSpecialCategory2:filterManager.selectedSpecialCategory2)
        }
    }
}

//MARK: Gestureの処理
extension MapView{
    private func handleDragChange(_ value:DragGesture.Value){
        let verticalTranslation = abs(value.translation.height)
        let horizontalTranslation = abs(value.translation.width)
        
        if verticalTranslation<60{
            withAnimation(.spring(response: 0.1, dampingFraction: 1, blendDuration: 0)) {
                previewDragOffset.height = value.translation.height
            }
        }
        if value.translation.height > 100{
            swipedDown = true
            swipedLeft = false //transitionのためスワイプされてる時から更新する
        }
        if value.translation.height < -100{//終わった時に開くじゃなくてSwipeの感が欲しいのでここで処理
            //swipe up
            previewDragOffset.height = value.translation.height
            vm.showDetailSheetView = true
            DispatchQueue.main.asyncAfter(deadline: .now()+0.8){//すぐ.zeroにならないように
                previewDragOffset = .zero //Sheetが表示されると handleDrageEnd　が呼ばれないから　ここでリセットさせる
            }
        }
        
        if horizontalTranslation < 50{
            withAnimation(.spring(response: 0.1, dampingFraction: 1, blendDuration: 0)) {
                previewDragOffset.width = value.translation.width
//                previewDragOffset = .zero //Sheetが表示されると handleDrageEnd　が呼ばれないから　ここでリセットさせる
            }
        }
    }
    private func handleDrageEnd(_ value:DragGesture.Value){
        withAnimation(.spring(response: 0.01, dampingFraction: 1, blendDuration: 0)) {
            previewDragOffset = .zero

            if value.translation.height > 100 {
                // swipe down
                swipedDown = true
                swipedLeft = false
                vm.selectedRestaurant = nil
            }
            if value.translation.width < -70{
                //swipe left
                swipedLeft = true
                swipedDown = false
                handleLeftSwipe(value:value)
            }
            if value.translation.width > 70{
                swipedLeft = false
                swipedDown = false
                //swipe right
                handleRightSwipe(value:value)
            }
        }
    }
    
    private func handleRightSwipe(value:DragGesture.Value){
        let currentShowingRestaurants = vm.showSearchedRestaurants ? vm.searchedRestaurants : vm.nearbyRestaurants
        //get the current selectedRestaurants index
        guard let currentIndex = currentShowingRestaurants.firstIndex(where: {$0 == vm.selectedRestaurant})else{
            print("Could not find current Index in restaucurrentShowingRestaurants array!")
            return
        }
        let previousIndex = currentIndex-1
        guard currentShowingRestaurants.indices.contains(previousIndex) else{
            //the start of the currentShowingRestaurants array
            //restart from last item
            guard let lastRestaurant = currentShowingRestaurants.last else{return}
            vm.showRestaurant(restaurant: lastRestaurant)
            return
        }
        let previousRestaurant = currentShowingRestaurants[previousIndex]
        vm.showRestaurant(restaurant: previousRestaurant)
    }
    
    private func handleLeftSwipe(value:DragGesture.Value){
        let currentShowingRestaurants = vm.showSearchedRestaurants ? vm.searchedRestaurants : vm.nearbyRestaurants
        
        //get the current selectedRestaurants index
        guard let currentIndex = currentShowingRestaurants.firstIndex(where: {$0 == vm.selectedRestaurant})else{
            print("Could not find current Index in restaucurrentShowingRestaurants array!")
            return
        }
        
        let nextIndex = currentIndex+1
        guard currentShowingRestaurants.indices.contains(nextIndex) else{
            //the end of the currentShowingRestaurants array
            //restart from 0
            guard let firstRestaurant = currentShowingRestaurants.first else {return}
            vm.showRestaurant(restaurant: firstRestaurant)
            return
        }
        
        let nextRestaurant = currentShowingRestaurants[nextIndex]
        vm.showRestaurant(restaurant: nextRestaurant)
    }
}


//MARK: ROUTE
extension MapView{
    private var tripDetailView:some View{
        VStack(alignment:.leading,spacing: 0){
            if let route = vm.selectedRoute{
                Group{
                    
                    var formattedDistance:String{
                        if route.distance < 1000{
                            //m
                            return "\(Int(route.distance))m"
                        }else{
                            //km
                            return String(format: "%.2fkm", Double(route.distance) / 1000)
                        }
                    }
                    Text(
                        "\(formatTimeInterval(route.expectedTravelTime))  (\(formattedDistance))"
                    )
                    .font(.title2)
                    .bold()
                    .padding(.top)
                    
                        let travelTime = route.expectedTravelTime
                        let calendar = Calendar.current
                        let minutes = Int(travelTime / 60) // If `travelTime` is in seconds
                        let date = calendar.date(byAdding: .minute, value: minutes, to: Date())
                        let formattedDate = date?.formatted(
                            Date.FormatStyle()
                                .hour(.twoDigits(amPM: .abbreviated))
                                .minute(.twoDigits)
                        )
                        
                        Text("到着：\(formattedDate ?? "到着時刻不明")")
                        
                        Text(route.steps.first?.instructions ?? "")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 25,weight: .light))
                            .padding(.bottom)
                    
                    
                }
                .padding(.leading)
            }
        }
        
    }
    
    private var cancelDestinationButton:some View{
        Button {
            withAnimation(.bouncy){
                vm.selectedRoute = nil
            }
        } label: {
            Image(systemName:"xmark.app")
                .font(.system(size: 30))
                .padding()
                .background(.red)
                .foregroundColor(.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.trailing)
        }
    }

    
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter.string(from: timeInterval) ?? "N/A"
    }
}

#Preview {
    MapView()
        .environmentObject(FilterManager())

}
#Preview {
    MapView()
        .environmentObject(FilterManager())
        .colorScheme(.dark)
}


