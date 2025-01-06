//
//  NearbyRestaurantSheetView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/26/24.
//

import SwiftUI
import MapKit
import Combine
import SDWebImageSwiftUI


struct NearbyRestaurantSheetView: View {
    @Binding var restaurantsShowing: [Shop]
    @Binding var selectedRestaurant: Shop?
    
    init(
        nearbyRestaurants: Binding<[Shop]>,
        cameraPosition: Binding<CLLocationCoordinate2D?>,
        selectedRestaurant: Binding<Shop?>
    ) {
        self._restaurantsShowing = nearbyRestaurants
        self._selectedRestaurant = selectedRestaurant
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("レストラン一覧")) {
                    if restaurantsShowing.isEmpty {
                        ContentUnavailableView("検索結果に一致するものはありません。", systemImage: "magnifyingglass")
                    } else {
                        ForEach(restaurantsShowing, id: \.id) { shop in
                            listItemView(for: shop)
                                .onTapGesture {
                                    selectedRestaurant = shop
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

extension NearbyRestaurantSheetView {
    private func listItemView(for shop: Shop) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let logoImage = shop.logoImage,
               logoImage != "https://imgfp.hotp.jp/SYS/cmn/images/common/diary/custom/m30_img_noimage.gif",
                let url = URL(string: logoImage) {
                WebImage(url: url)
                    .placeholder {
                        shop.genre.image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            }else{
                shop.genre.image
                    .resizable()
                    .scaledToFill()
                    .frame(width:50,height:50)
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(shop.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(shop.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)

                HStack {
                    Image(systemName:"person.2")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("宴会収容人数: \(shop.partyCapacity?.displayValue ?? "不明")")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }

                if let cardInfo = shop.card, !cardInfo.isEmpty {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("カード: \(cardInfo)")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.systemBlack.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    photo: Photo(pc: PCPhoto(l: "large_url", m: "medium_url", s: "small_url"), mobile: MobilePhoto(l: "large", s: "small")), catchPharse: "afd",
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
                    open: "月～日、祝日: 11:00～15:30 （料理L.O. 15:00）17:00～23:00",
                    close: "9:00 PM",
                    parking: "Yes",
                    nonSmoking: "Yes",
                    card: "利用可"
                )
            ]
    NearbyRestaurantSheetView(nearbyRestaurants: .constant(dummyShops), cameraPosition: .constant(CLLocationCoordinate2D(latitude: 35.7020691, longitude: 139.7753269)), selectedRestaurant: .constant(dummyShops[0]))
    }

