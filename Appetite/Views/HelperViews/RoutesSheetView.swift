//
//  RotesSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/1/25.
//

import SwiftUI
import MapKit

//Pickerで使うため
extension MKDirectionsTransportType: Hashable {}

struct RoutesSheetView: View {
    var getRoutes: () -> Void
    @Binding var availableRoutes: [MKRoute]
    @Binding var selectedRoute: MKRoute?
    @Binding var transportType: MKDirectionsTransportType
    
    var body: some View {
        VStack(spacing: 20) {
            // Transport Type Picker
            Picker("移動手段", selection: $transportType) {
                Image(systemName: "figure.walk")
                    .font(.headline)
                    .tag(MKDirectionsTransportType.walking)
                Image(systemName:"car.fill")
                    .font(.headline)
                    .tag(MKDirectionsTransportType.automobile)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .shadow(radius: 5)
            
            // Display Routes
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

struct RouteRowView: View {
    @Environment(\.dismiss) var dismiss
    var route: MKRoute
    @Binding var selectedRoute:MKRoute?
    var body: some View {
        HStack {
            VStack(alignment: .leading) {

                var formattedTravelTime: String {
                    let totalSeconds = Int(route.expectedTravelTime)
                    let hours = totalSeconds / 3600
                    let minutes = (totalSeconds % 3600) / 60
                    let seconds = totalSeconds % 60

                    if hours > 0 {
                        return String(format: "%d hr %d min", hours, minutes)
                    } else if minutes > 0 {
                        return String(format: "%d min %d sec", minutes, seconds)
                    } else {
                        return String(format: "%d sec", seconds)
                    }
                }
                
                Text(formattedTravelTime)
                    .font(.title)
                    .bold()
                
                if route.hasHighways{
                    Text("高速道路利用")
                }

            
                var formattedDistance:String{
                    if route.distance < 1000{
                        //m
                        return "\(Int(route.distance))m"
                    }else{
                        //km
                        return String(format: "%.2fkm", Double(route.distance) / 1000)
                    }
                }
                
                Text(formattedDistance)
                    .font(.headline)
                
                let travelTime = route.expectedTravelTime
                    let calendar = Calendar.current
                    let minutes = Int(travelTime / 60)
                    let date = calendar.date(byAdding: .minute, value: minutes, to: Date())
                    let formattedDate = date?.formatted(
                        Date.FormatStyle()
                            .hour(.twoDigits(amPM: .abbreviated))
                            .minute(.twoDigits)
                    )
                    
                Text("到着: \(formattedDate ?? "不明")")
                    .font(.subheadline)
            }
            Spacer()
            Button {
                selectedRoute = route
                dismiss.callAsFunction()
            } label: {
                Text("出発")
                    .font(.headline)
                    .padding()
                    .frame(width: 100,height:55)
                    .background(.green)
                    .foregroundStyle(.systemBlack)
                    .cornerRadius(10)
            }

        }
        .foregroundStyle(.systemBlack)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
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
