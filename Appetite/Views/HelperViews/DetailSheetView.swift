//
//  DetailSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/31/24.
//


import SwiftUI
import SDWebImageSwiftUI

struct DetailSheetView: View {
    @Environment(\.dismiss) var dismiss
    let shop: Shop
    @Binding var showRoutesSheet:Bool
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Shop name and address
                    if !shop.catchPharse.isEmpty{
                        Text(shop.catchPharse)
                            .font(.title3)
                            .bold()
                    }
                    
                    
                    
                    Text(shop.address)
                        .font(.subheadline)
                        .textSelection(.enabled)
                    
                    // Access information
                    Text(shop.access)
                        .font(.caption)
                    
                    VStack(alignment:.leading,spacing: .zero) {
                        Text("ホームページ")
                            .font(.caption)
                        if let url = URL(string: shop.urls.pc){
                            Link(shop.name, destination: url)
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    
                    // Photos
                    let urlString = shop.photo.pc.l
                    let url = URL(string: urlString)
                    WebImage(url: url)
                        .placeholder(content: {
                            Image(.placeholder)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(15)
                                .clipped()
                                .shadow(radius: 10)
                        })
                        .resizable()
                        .frame(height: 250)
                        .scaledToFit()
                        .cornerRadius(15)
                        .clipped()
                        .shadow(radius: 10)
                    
                    Label("営業時間", systemImage: "clock")
                        .bold()
                    Text(formatOperatingHours(shop.open))
                    
                    GroupBox("その他詳細"){
                        // Additional shop details in a grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            detailRow(title: "ジャンル", value: shop.genre.name)
                            detailRow(title: "サブジャンル", value: shop.subGenre?.name ?? "なし")
                            detailRow(title: "駅", value: shop.stationName ?? "なし")
                            detailRow(title: "宴会収容人数", value: "\(shop.partyCapacity?.displayValue ?? "") 人")
                            detailRow(title: "Wi-Fi", value: shop.wifi ?? "不明")
                            detailRow(title: "個室", value: shop.privateRoom ?? "不明")
                            detailRow(title: "飲み放題", value: shop.freeDrink ?? "不明")
                            detailRow(title: "食べ放題", value: shop.freeFood ?? "不明")
                            detailRow(title: "定休", value: shop.close ?? "不明")
                            detailRow(title: "駐車場", value: shop.parking ?? "不明")
                            detailRow(title: "喫煙席", value: shop.nonSmoking ?? "不明")
                            detailRow(title: "平均ディナー予算", value: formatBudgetString(shop.budget?.average))
                            detailRow(title: "料金備考", value: shop.budget?.budgetMemo ?? "なし")
                            detailRow(title: "カード", value: shop.card ?? "不明")
                        }
                    }
                    .padding(.bottom,70)//経路Buttonのためスペース
                    
                    // Button for directions
                    Spacer()
                }
                .padding()
            }
            .overlay(alignment: .bottom) {
                Button {
                    // Action for directions button
                    dismiss.callAsFunction()
                    showRoutesSheet = true
                } label: {
                    Text("経路")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .shadow(color: Color.blue.opacity(0.4), radius: 10, y: -5)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            
            .navigationTitle(shop.name)
        }
        //        .background(.systemWhite)
        .cornerRadius(15)
        .shadow(radius: 10)
        .foregroundStyle(.systemBlack)
    }
    
    // Helper function to display a detail row
    private func detailRow(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.systemBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
        .padding(.vertical, 5)
    }
    
    private func formatOperatingHours(_ rawString: String?) -> String {
        guard let rawString = rawString,
            !rawString.isEmpty else{
            return "不明"
        }
        let pattern = "(\\d{2}:\\d{2}～\\d{2}:\\d{2})(?=\\d{2}:\\d{2}～\\d{2}:\\d{2})"//時間のパタン 例：12:00
        let formattedString = rawString
            .replacingOccurrences(of: " ", with: "\n")
            .replacingOccurrences(of: "（", with: "\n",options: .regularExpression)
            .replacingOccurrences(of: "）", with: "",options: .regularExpression)
            .replacingOccurrences(of: "(L\\.O\\.)", with: "\nラストオーダー", options: .regularExpression)
            .replacingOccurrences(of: pattern, with: "$1, ",options: .regularExpression) //12:0013:00 -> 12:00, 13:00
        print(rawString)
        return formattedString
    }
    private func formatBudgetString(_ rawString:String?) -> String{
        guard let rawString = rawString,
              !rawString.isEmpty else{
            return "不明"
        }
        let formattedString = rawString
            .replacingOccurrences(of: "、", with: "\n")
            .replacingOccurrences(of: "：", with: "\n")
        
        return formattedString
    }
    
}

#Preview {
    let dummyShops = [
        Shop(
            id: "1",
            name: "韓国居酒屋 板橋冷麺 新大久保",
            address: "東京都新宿区百人町１-21-4",
            lat: 35.6895,
            lon: 139.6917,
            genre: Genre(code: "1", name: "居酒屋"), subGenre: SubGenre(name: "ダイニングバー", code: "fadsf"),
            access: "2 mins from Station",
            urls: URLs(pc: "https://example.com"),
            photo: Photo(pc: PCPhoto(l: "https://example.com/photo.jpg", m: "medium_url", s: "small_url"), mobile: MobilePhoto(l: "large", s: "snall")), catchPharse: "一番美味しいラーメン",
            logoImage: "logoA.png",
            nameKana: "レストラン A",
            stationName: "Station A",
            ktaiCoupon: 10,
            budget: Budget(code: "1", name: "Affordable", average: "ランチ：～999円、ディナー：3000円～4000円", budgetMemo: "Reasonable"), partyCapacity: .string("10"),
            capacity: .integer(10),
            wifi: "Available",
            course: "Yes",
            freeDrink: "No",
            freeFood: "Yes",
            privateRoom: "Yes",
            open: "月～日、祝日、祝前日: 11:00～15:0017:00～23:00（料理ラストオーダー 22:30 ドリンクラストオーダー 22:30）",
            close: "9:00 PM",
            parking: "Yes",
            nonSmoking: "Yes",
            card: "Visa"
        )
    ]
    NavigationStack{
        DetailSheetView(shop: dummyShops[0], showRoutesSheet: .constant(false))
    }
}
