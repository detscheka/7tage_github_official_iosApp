//
//  TestManager.swift
//  Indizenz-App (iOS)
//
//  Created by Tschekalinskij, Alexander on 3/7/21.
//

import UIKit
import CoreLocation

class TestManager: CLLocationManager, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    private var handler: ((CLLocation) -> Void)?

    override init() {
        super.init()
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            if self.locationManager!.authorizationStatus == .notDetermined {
                self.locationManager!.requestWhenInUseAuthorization()
            }
        }
    }
    
    func fetchLocation(handler: @escaping (CLLocation) -> Void) {
        self.handler = handler
        self.locationManager!.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.handler!(locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
