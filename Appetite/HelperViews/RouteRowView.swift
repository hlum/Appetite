//
//  RouteRowView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/7/25.
//

import Foundation
import SwiftUI
import MapKit

struct RouteRowView: View {
    @Environment(\.dismiss) var dismiss
    var route: MKRoute
    @Binding var selectedRoute:MKRoute?
    var body: some View {
        HStack {
            VStack(alignment: .leading) {

                travelTime
                if route.hasHighways{
                    Text("高速道路利用")
                }
                formattedDistance
                arrivalTime
            }
            Spacer()
            goButton//出発ボタン
        }
        .foregroundStyle(.systemBlack)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}


extension RouteRowView{
    private var travelTime:some View{
        VStack{
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
        }

    }
    
    private var formattedDistance:some View{
        VStack{
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
            
        }
    }
    
    private var arrivalTime:some View{
        VStack{
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
    }
    
    private var goButton:some View{
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
}
