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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        NotificationCenter.default.post(name: Notification.Name("UserLocationUpdated"), object: nil) // ユーザーの一致が変わったらルートを更新するため
        onLocationUpdate?(.success(newLocation.coordinate))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onLocationUpdate?(.failure(error))
    }

}
