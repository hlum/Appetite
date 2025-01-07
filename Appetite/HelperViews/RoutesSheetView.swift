//
//  RotesSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/1/25.
//

import SwiftUI
import MapKit

//Pickerで使うため
extension MKDirectionsTransportType: @retroactive Hashable {}

struct RoutesSheetView: View {
    var getRoutes: () -> Void
    @Binding var selectedRestaurant:Shop?
    @Binding var availableRoutes: [MKRoute]
    @Binding var selectedRoute: MKRoute?
    @Binding var transportType: MKDirectionsTransportType
    
    var body: some View {
        VStack(spacing: 20) {
            transportTypePicker
            
            if transportType != .transit{
                routesOrUnavailableView
            }else{ //公共交通機関の場合はMap、Google Mapへ誘導する
                VStack{
                    if let selectedRestaurant = selectedRestaurant{
                        mapButton(
                            title: "Mapで開く",
                            url: "maps://?saddr=&daddr=",
                            lat: selectedRestaurant.lat,
                            lon: selectedRestaurant.lon
                        )
                        
                        mapButton(
                            title: "Google Mapで開く",
                            url: "https://www.google.com/maps/dir/?api=1&origin=&destination=",
                            lat: selectedRestaurant.lat,
                            lon: selectedRestaurant.lon
                        )
                    }
                }
            }
            
            Spacer()
        }
        .foregroundStyle(.systemBlack)
        .onAppear {
            getRoutes()
        }
        .onChange(of: transportType) { _, _ in
            getRoutes()
        }
        .padding()
    }
}

extension RoutesSheetView{
    private var transportTypePicker:some View{
        Picker("移動手段", selection: $transportType) {
            Image(systemName: "figure.walk")
                .font(.headline)
                .tag(MKDirectionsTransportType.walking)
            Image(systemName:"car.fill")
                .font(.headline)
                .tag(MKDirectionsTransportType.automobile)
            Image(systemName: "train.side.rear.car")
                .font(.headline)
                .tag(MKDirectionsTransportType.transit)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .shadow(radius: 5)
    }
    
    private var routesOrUnavailableView:some View{
        VStack{
            if !availableRoutes.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(availableRoutes, id: \.self) { route in
                            RouteRowView(route: route, selectedRoute: $selectedRoute)
                        }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView("案内可能なルートはありません。", systemImage: "x.circle")
                    .padding(.top, 20)
            }
        }
    }
    
    func mapButton(title: String, url: String, lat: Double, lon: Double) -> some View {
        Button {
            if let url = URL(string: "\(url)\(lat),\(lon)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
        }
    }
    
}

//
//#Preview {
//    @Previewable @State var availableRoutes:[MKRoute] = [MKRou]
//    @Previewable @State var selectedRoute:MKRoute?
//    @Previewable @State var transportType: MKDirectionsTransportType
//    @Previewable @State var transportType:MKDirectionsTransportType = .transit
//    RotesSheetView(transportType: $transportType)
//}
