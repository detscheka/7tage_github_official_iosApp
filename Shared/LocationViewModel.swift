//
//  LocationViewModel.swift
//  Inzidenz-App
//
//  Created by Tschekalinskij, Alexander on 3/8/21.
//

import UIKit
import WidgetKit
import Foundation
import Combine
import CoreLocation

class LocationViewModel: NSObject, ObservableObject{
  
    @Published var userLatitude: Double = 0
    @Published var userLongitude: Double = 0
    @Published var userTown: String = ""
    @Published var incidency: Int = 0
    @Published var color: UIColor = UIColor.green
  
  private let locationManager = CLLocationManager()
  
  override init() {
    super.init()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
  }
}

extension LocationViewModel: CLLocationManagerDelegate {
    
    struct ReversedGeoLocation {
        let name: String            // eg. Apple Inc.
        let streetName: String      // eg. Infinite Loop
        let streetNumber: String    // eg. 1
        let city: String            // eg. Cupertino
        let state: String           // eg. CA
        let zipCode: String         // eg. 95014
        let country: String         // eg. United States
        let isoCountryCode: String  // eg. US

        var formattedAddress: String {
            return """
            \(name),
            \(streetNumber) \(streetName),
            \(city), \(state) \(zipCode)
            \(country)
            """
        }

        // Handle optionals as needed
        init(with placemark: CLPlacemark) {
            self.name           = placemark.name ?? ""
            self.streetName     = placemark.thoroughfare ?? ""
            self.streetNumber   = placemark.subThoroughfare ?? ""
            self.city           = placemark.locality ?? ""
            self.state          = placemark.administrativeArea ?? ""
            self.zipCode        = placemark.postalCode ?? ""
            self.country        = placemark.country ?? ""
            self.isoCountryCode = placemark.isoCountryCode ?? ""
        }
    }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    userLatitude = location.coordinate.latitude
    userLongitude = location.coordinate.longitude
    
    let loc = CLLocation.init(latitude: userLatitude, longitude: userLongitude)
    CLGeocoder().reverseGeocodeLocation(loc) { placemarks, error in

        guard let placemark = placemarks?.first else {
            let errorString = error?.localizedDescription ?? "Unexpected Error"
            print("Unable to reverse geocode the given location. Error: \(errorString)")
            return
        }

        let reversedGeoLocation = ReversedGeoLocation(with: placemark)
        print(reversedGeoLocation.city)
        DispatchQueue.main.async {
//            self.userTown = reversedGeoLocation.city
            if (reversedGeoLocation.country != "Germany")
            {
                return
            }
        }
    }
    
//    getTown(lat: CLLocationDegrees.init(userLatitude), long: CLLocationDegrees.init(userLongitude))
    getData()
    
    WidgetCenter.shared.reloadAllTimelines()

    print(location)
  }
    
    func getTown(lat: CLLocationDegrees, long: CLLocationDegrees) -> Void
    {
            let location = CLLocation.init(latitude: lat, longitude: long)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

                guard let placemark = placemarks?.first else {
                    let errorString = error?.localizedDescription ?? "Unexpected Error"
                    print("Unable to reverse geocode the given location. Error: \(errorString)")
                    return
                }

                let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                print(reversedGeoLocation.city)
                DispatchQueue.main.async {
//                    self.userTown = reversedGeoLocation.city
                }
            }
    }
    
    func getData()
    {
        let lat3 = String(format: "%.3f", self.userLatitude)
        let long3 = String(format: "%.3f", self.userLongitude)
        var incidency = 0
        var color = UIColor.green
        
        
        let loc = CLLocation.init(latitude: self.userLatitude, longitude: self.userLongitude)
        CLGeocoder().reverseGeocodeLocation(loc) { placemarks, error in

            guard let placemark = placemarks?.first else {
                let errorString = error?.localizedDescription ?? "Unexpected Error"
                print("Unable to reverse geocode the given location. Error: \(errorString)")
                return
            }

            let reversedGeoLocation = ReversedGeoLocation(with: placemark)
            print(reversedGeoLocation.city)
            DispatchQueue.main.async {
//                self.userTown = reversedGeoLocation.city
                if (reversedGeoLocation.country != "Germany")
                {
                    return
                }
            }
        }
        
        if let url = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=1%3D1&outFields=RS,GEN,cases7_bl_per_100k,cases7_per_100k,BL&geometry=\(long3)%2C\(lat3)&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelWithin&returnGeometry=false&outSR=4326&f=json") {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                 if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                    let array = jsonString.components(separatedBy: ":")
                    let interestingVal = array[array.count - 2]
                    let arrTwo = interestingVal.components(separatedBy: ",")
                    var incid = Double(arrTwo[0])
                    
                    if (incid == nil)
                    {
                        return
                    }
                    
                    incid = floor(incid!)
                    print(incid)
                    
                    let landkreisVal = array[array.count - 4]
                    let arrLandkreis = landkreisVal.components(separatedBy: ",")
                    var landkreis = arrLandkreis[0]
                    print(landkreis)
                    landkreis = landkreis.replacingOccurrences(of: "\"", with: "")
                    
                    self.userTown = landkreis
                    self.incidency = Int(incid!)
                    
                    DispatchQueue.main.async {
                        self.userTown = landkreis
                        self.incidency = Int(incid!)
                    }
                    
                    incidency = Int(ceil(incid!))
                    
                    if (incidency <= 35)
                    {
                        color = UIColor.init(red: 159/255, green: 252/255, blue: 172/255, alpha: 1)
                    }
                    
                    if ((incidency <= 50) && (incidency > 35))
                    {
                        color = UIColor.init(red: 228/255, green: 210/255, blue: 88/255, alpha: 1)
                    }
                    
                    if ((incidency <= 100) && (incidency > 50))
                    {
                        color = UIColor.init(red: 191/255, green: 71/255, blue: 42/255, alpha: 1)
                    }
                    
                    if ((incidency <= 200) && (incidency > 100))
                    {
                        color = UIColor.init(red: 136/255, green: 37/255, blue: 17/255, alpha: 1)
                    }
                    
                    if ((incidency <= 300) && (incidency > 200))
                    {
                        color = UIColor.init(red: 49/255, green: 13/255, blue: 4/255, alpha: 1)
                    }
                    
                    if ((incidency > 400))
                    {
                        color = UIColor.init(red: 20/255, green: 5/255, blue: 1/255, alpha: 1)
                    }
                    
                    self.color = color
                    DispatchQueue.main.async {
                        self.color = color
                    }
                 }
               }
           }.resume()
        }
    }
}
