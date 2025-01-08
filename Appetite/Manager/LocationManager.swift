//
//  LocationManager.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import Foundation
import CoreLocation


final class LocationManager:NSObject,CLLocationManagerDelegate{
    private let locationManager = CLLocationManager()
    var onLocationUpdate:((Result<CLLocationCoordinate2D,Error>)->())?
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Use best available accuracy
        locationManager.distanceFilter = 3; // 位置情報取得間隔を指定(3m移動したら、位置情報を通知)

        setup()
    }
    
    private func setup(){
        checkLocationAuthorization()
    }
    
    //位置情報の許可をチェック
    //許可あったら位置情報を取得、許可なかったら許可をリクエスト
    func checkLocationAuthorization(){
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("Requesting location authorization")
        case .denied, .restricted:
            print("Location access denied or restricted. Guide user to Settings.")
            onLocationUpdate?(.failure(CustomErrors.LocationPermissionDenied))
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
            print("Unknown authorization status")
        }
    }
    
    //MARK: CLLocationManagerDelegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    //10m移動したら呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        // ユーザーの一致が変わったらルートを更新するため
        NotificationCenter.default.post(name: Notification.Name("UserLocationUpdated"), object: nil)
        
        let howRecent = newLocation.timestamp.timeIntervalSinceNow
        // 15秒以上経過したデータは破棄する
        //(最初の画面でキャッシュされている位置情報でレストランを検索されてしまうと検索結果がないBugが出ます。）
//        guard abs(howRecent) < 15.0,
//              // 垂直精度が半径100m以下のみ、有効な位置情報として扱う
//              newLocation.horizontalAccuracy < 100,
//              newLocation.coordinate.latitude != 0.0,
//              newLocation.coordinate.longitude != 0.0 else {
//            return
//        }
        onLocationUpdate?(.success(newLocation.coordinate))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed: \(error.localizedDescription)")
        if let clError = error as? CLError{
            if clError.code == .denied{
                onLocationUpdate?(.failure(CustomErrors.LocationPermissionDenied))
            }
        }
    }

}
