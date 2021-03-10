//
//  Inzidenz_Widget.swift
//  Inzidenz-Widget
//
//  Created by Tschekalinskij, Alexander on 3/7/21.
//

import WidgetKit
import SwiftUI
import CoreLocation

struct Provider: TimelineProvider {
    var widgetLocationManager = WidgetLocationManager()
    
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
    
    struct Response: Codable { // or Decodable
      let cases7_per_100k: Double
    }
    
    struct DemoData: Codable {
        let title: String
        let description: String
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        var town = "Nürnberg"
        var lat = 49.452
        var long = 11.077
        var incidency = 15
        var color = Color.green
        
        widgetLocationManager.fetchLocation(handler: { location in
            print(location.coordinate.longitude)
            print(location.coordinate.latitude)
            
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            
            let location = CLLocation(latitude: lat, longitude: long)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

                guard let placemark = placemarks?.first else {
                    let errorString = error?.localizedDescription ?? "Unexpected Error"
                    print("Unable to reverse geocode the given location. Error: \(errorString)")
                    return
                }

                let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                print(reversedGeoLocation.city)
                
                town = reversedGeoLocation.city
            }
        })
        
        widgetLocationManager.fetchLocation(handler: { location in
                print(location)
            })
        
        return SimpleEntry(date: Date(), longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: 0, townSearch: "", incidencySearch: 75, colorSearch: Color.init(.sRGB, red: 191/255, green: 71/255, blue: 42/255, opacity: 1))
    }
    
    private func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(DemoData.self,
                                                       from: jsonData)
            
            print("Title: ", decodedData.title)
            print("Description: ", decodedData.description)
            print("===================================")
        } catch {
            print("decode error")
        }
    }
    
    func readFromDefaultDouble(key : String, defVal : Double) -> Double
    {
        if let userDefaults = UserDefaults(suiteName: "group.BAgames.incidency") {
            let val = userDefaults.double(forKey: key)
            return val
        } else {
            return defVal
        }
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        var town = "Nürnberg"
        var lat = 49.452
        var long = 11.077
        var incidency = 15
        var color = Color.green
        
        widgetLocationManager.fetchLocation(handler: { location in
            print(location.coordinate.longitude)
            print(location.coordinate.latitude)
            
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            
            let location = CLLocation(latitude: lat, longitude: long)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

                guard let placemark = placemarks?.first else {
                    let errorString = error?.localizedDescription ?? "Unexpected Error"
                    print("Unable to reverse geocode the given location. Error: \(errorString)")
                    return
                }

                let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                print(reversedGeoLocation.city)
                
                town = reversedGeoLocation.city
            }
        })
        
        let entry = SimpleEntry(date: Date(), longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: 0, townSearch: "", incidencySearch: 75, colorSearch: Color.init(.sRGB, red: 191/255, green: 71/255, blue: 42/255, opacity: 1))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        var town = "Nürnberg"
        var lat = 49.452
        var long = 11.077
        var incidency = 15
        var color = Color.green
        
        var townSearch = ""
        var incidencySearch = 0
        var colorSearch = Color.green
        
        var two = 0
        var locationManagerEntered = 0
        
        widgetLocationManager.fetchLocation(handler: { location in
            print(location.coordinate.longitude)
            print(location.coordinate.latitude)
            
            locationManagerEntered = 1
            
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            
            let lat3 = String(format: "%.3f", lat)
            let long3 = String(format: "%.3f", long)
            
            print(lat3)
            print(long3)
            
            let location = CLLocation(latitude: lat, longitude: long)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

                guard let placemark = placemarks?.first else {
                    let errorString = error?.localizedDescription ?? "Unexpected Error"
                    print("Unable to reverse geocode the given location. Error: \(errorString)")
                    return
                }

                let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                print(reversedGeoLocation.city)
                
                town = reversedGeoLocation.city
//                WidgetCenter.shared.reloadAllTimelines()
                
                if let url = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=1%3D1&outFields=RS,GEN,cases7_bl_per_100k,cases7_per_100k,BL&geometry=\(long3)%2C\(lat3)&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelWithin&returnGeometry=false&outSR=4326&f=json") {
                   URLSession.shared.dataTask(with: url) { data, response, error in
                      if let data = data {
                         if let jsonString = String(data: data, encoding: .utf8) {
                            print(jsonString)
                            let array = jsonString.components(separatedBy: ":")
                            let interestingVal = array[array.count - 2]
                            let arrTwo = interestingVal.components(separatedBy: ",")
                            var incid = Double(arrTwo[0])
                            incid = floor(incid!)
                            print(incid)
                            
                            let landkreisVal = array[array.count - 4]
                            let arrLandkreis = landkreisVal.components(separatedBy: ",")
                            var landkreis = arrLandkreis[0]
                            print(landkreis)
                            landkreis = landkreis.replacingOccurrences(of: "\"", with: "")
                            town = landkreis
                            
                            incidency = Int(ceil(incid!))
                            
                            if (incidency <= 35)
                            {
                                color = Color.init(.sRGB, red: 159/255, green: 252/255, blue: 172/255, opacity: 1)
                            }
                            
                            if ((incidency <= 50) && (incidency > 35))
                            {
                                color = Color.init(.sRGB, red: 228/255, green: 210/255, blue: 88/255, opacity: 1)
                            }
                            
                            if ((incidency <= 100) && (incidency > 50))
                            {
                                color = Color.init(.sRGB, red: 191/255, green: 71/255, blue: 42/255, opacity: 1)
                            }
                            
                            if ((incidency <= 200) && (incidency > 100))
                            {
                                color = Color.init(.sRGB, red: 136/255, green: 37/255, blue: 17/255, opacity: 1)
                            }
                            
                            if ((incidency <= 300) && (incidency > 200))
                            {
                                color = Color.init(.sRGB, red: 49/255, green: 13/255, blue: 4/255, opacity: 1)
                            }
                            
                            if ((incidency > 300))
                            {
                                color = Color.init(.sRGB, red: 20/255, green: 5/255, blue: 1/255, opacity: 1)
                            }
                            
                            var userSearchLong = readFromDefaultDouble(key: "userSearchLong", defVal: 0.0)
                            var userSearchLat = readFromDefaultDouble(key: "userSearchLat", defVal: 0.0)
                            
                            print("Color before if")
                            print(color)
                            print(incidency)
                            
                            if ((userSearchLong != 0) && (userSearchLat != 0))
                            {
                                /* Display also second town data */
                                two = 1
                                
                                let lat3user = String(format: "%.3f", userSearchLat)
                                let long3user = String(format: "%.3f", userSearchLong)
                                
                                let locationUser = CLLocation(latitude: userSearchLat, longitude: userSearchLong)
                                CLGeocoder().reverseGeocodeLocation(locationUser) { placemarks, error in

                                    guard let placemark = placemarks?.first else {
                                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                                        return
                                    }

                                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                                    print(reversedGeoLocation.city)
                                    
                                    if let url = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=1%3D1&outFields=RS,GEN,cases7_bl_per_100k,cases7_per_100k,BL&geometry=\(long3user)%2C\(lat3user)&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelWithin&returnGeometry=false&outSR=4326&f=json") {
                                       URLSession.shared.dataTask(with: url) { data, response, error in
                                          if let data = data {
                                             if let jsonString = String(data: data, encoding: .utf8) {
                                                print(jsonString)
                                                let array = jsonString.components(separatedBy: ":")
                                                let interestingVal = array[array.count - 2]
                                                let arrTwo = interestingVal.components(separatedBy: ",")
                                                var incid = Double(arrTwo[0])
                                                incid = floor(incid!)
                                                print(incid)
                                                
                                                let landkreisVal = array[array.count - 4]
                                                let arrLandkreis = landkreisVal.components(separatedBy: ",")
                                                var landkreis = arrLandkreis[0]
                                                print(landkreis)
                                                landkreis = landkreis.replacingOccurrences(of: "\"", with: "")
                                                townSearch = landkreis
                                                
                                                incidencySearch = Int(ceil(incid!))
                                                print("incidencySearch = \(incidencySearch)")
                                                
                                                if (incidencySearch <= 35)
                                                {
                                                    colorSearch = Color.init(.sRGB, red: 159/255, green: 252/255, blue: 172/255, opacity: 1)
                                                }
                                                
                                                if ((incidencySearch <= 50) && (incidencySearch > 35))
                                                {
                                                    colorSearch = Color.init(.sRGB, red: 228/255, green: 210/255, blue: 88/255, opacity: 1)
                                                }
                                                
                                                if ((incidencySearch <= 100) && (incidencySearch > 50))
                                                {
                                                    colorSearch = Color.init(.sRGB, red: 191/255, green: 71/255, blue: 42/255, opacity: 1)
                                                }
                                                
                                                if ((incidencySearch <= 200) && (incidencySearch > 100))
                                                {
                                                    colorSearch = Color.init(.sRGB, red: 136/255, green: 37/255, blue: 17/255, opacity: 1)
                                                }
                                                
                                                if ((incidencySearch <= 300) && (incidencySearch > 200))
                                                {
                                                    colorSearch = Color.init(.sRGB, red: 49/255, green: 13/255, blue: 4/255, opacity: 1)
                                                }
                                                
                                                if ((incidencySearch > 300))
                                                {
                                                    colorSearch = Color.init(.sRGB, red: 20/255, green: 5/255, blue: 1/255, opacity: 1)
                                                }
                                                
                                                print("User saved data in if:")
                                                print(townSearch)
                                                print(incidencySearch)
                                                print(colorSearch)
                                                
                                                print("Color:")
                                                print(color)
                                                
                                                let entry = SimpleEntry(date: currentDate, longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: 1, townSearch: townSearch, incidencySearch: incidencySearch, colorSearch: colorSearch)

                                                let timeline = Timeline(entries: [entry], policy: .atEnd)
                                                completion(timeline)
                                             }
                                           }
                                       }.resume()
                                    }
                                }
                            }
                            
                            print("User saved data:")
                            print(townSearch)
                            print(incidencySearch)
                            print(colorSearch)
                            
                            if (two == 0)
                            {
                                let entry = SimpleEntry(date: currentDate, longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: two, townSearch: townSearch, incidencySearch: incidencySearch, colorSearch: colorSearch)

                                let timeline = Timeline(entries: [entry], policy: .atEnd)
                                completion(timeline)
                            }
                         }
                       }
                   }.resume()
                }
            }
        })
    
        if (locationManagerEntered == 0)
        {
            /* GPS seems unavailable. Check if second location is present */
            
            var userSearchLong = readFromDefaultDouble(key: "userSearchLong", defVal: 0.0)
            var userSearchLat = readFromDefaultDouble(key: "userSearchLat", defVal: 0.0)
            
            if ((userSearchLong != 0) && (userSearchLat != 0))
            {
                /* Display also second town data */
                two = 1
                
                let lat3user = String(format: "%.3f", userSearchLat)
                let long3user = String(format: "%.3f", userSearchLong)
                
                let locationUser = CLLocation(latitude: userSearchLat, longitude: userSearchLong)
                CLGeocoder().reverseGeocodeLocation(locationUser) { placemarks, error in

                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }

                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                    print(reversedGeoLocation.city)
                    
                    if let url = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=1%3D1&outFields=RS,GEN,cases7_bl_per_100k,cases7_per_100k,BL&geometry=\(long3user)%2C\(lat3user)&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelWithin&returnGeometry=false&outSR=4326&f=json") {
                       URLSession.shared.dataTask(with: url) { data, response, error in
                          if let data = data {
                             if let jsonString = String(data: data, encoding: .utf8) {
                                print(jsonString)
                                let array = jsonString.components(separatedBy: ":")
                                let interestingVal = array[array.count - 2]
                                let arrTwo = interestingVal.components(separatedBy: ",")
                                var incid = Double(arrTwo[0])
                                incid = floor(incid!)
                                print(incid)
                                
                                let landkreisVal = array[array.count - 4]
                                let arrLandkreis = landkreisVal.components(separatedBy: ",")
                                var landkreis = arrLandkreis[0]
                                print(landkreis)
                                landkreis = landkreis.replacingOccurrences(of: "\"", with: "")
                                townSearch = landkreis
                                
                                incidencySearch = Int(ceil(incid!))
                                print("incidencySearch = \(incidencySearch)")
                                
                                if (incidencySearch <= 35)
                                {
                                    colorSearch = Color.init(.sRGB, red: 159/255, green: 252/255, blue: 172/255, opacity: 1)
                                }
                                
                                if ((incidencySearch <= 50) && (incidencySearch > 35))
                                {
                                    colorSearch = Color.init(.sRGB, red: 228/255, green: 210/255, blue: 88/255, opacity: 1)
                                }
                                
                                if ((incidencySearch <= 100) && (incidencySearch > 50))
                                {
                                    colorSearch = Color.init(.sRGB, red: 191/255, green: 71/255, blue: 42/255, opacity: 1)
                                }
                                
                                if ((incidencySearch <= 200) && (incidencySearch > 100))
                                {
                                    colorSearch = Color.init(.sRGB, red: 136/255, green: 37/255, blue: 17/255, opacity: 1)
                                }
                                
                                if ((incidencySearch <= 300) && (incidencySearch > 200))
                                {
                                    colorSearch = Color.init(.sRGB, red: 49/255, green: 13/255, blue: 4/255, opacity: 1)
                                }
                                
                                if ((incidencySearch > 300))
                                {
                                    colorSearch = Color.init(.sRGB, red: 20/255, green: 5/255, blue: 1/255, opacity: 1)
                                }
                                
                                print("User saved data in if:")
                                print(townSearch)
                                print(incidencySearch)
                                print(colorSearch)
                                
                                print("Color:")
                                print(color)
                                
                                let entry = SimpleEntry(date: currentDate, longitude: Float(long), latitude: Float(lat), town: "", incidency: Int(incidency), color: color, twoLocations: 1, townSearch: townSearch, incidencySearch: incidencySearch, colorSearch: colorSearch)

                                let timeline = Timeline(entries: [entry], policy: .atEnd)
                                completion(timeline)
                             }
                           }
                       }.resume()
                    }
                }
            } else {
                let entry = SimpleEntry(date: currentDate, longitude: Float(long), latitude: Float(lat), town: "", incidency: Int(incidency), color: color, twoLocations: two, townSearch: townSearch, incidencySearch: incidencySearch, colorSearch: colorSearch)

                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let longitude: Float
    let latitude: Float
    let town: String
    let incidency: Int
    let color: Color
    let twoLocations: Int
    
    let townSearch: String
    let incidencySearch: Int
    let colorSearch: Color
}

struct Inzidenz_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack (alignment: .center, spacing: 5) {
            Spacer()
            
                VStack (alignment: .center, spacing: 2) {
                    VStack (alignment: .center, spacing: 5) {
                        Spacer()
                        Text("7-Tages-Wert").foregroundColor(.black).font(.system(size: CGFloat(10.0)))
                        
                        Divider().foregroundColor(.black)
                        
                        if (entry.town == "")
                        {
                            Text("GPS nicht verfügbar oder Ort außerhalb von Deutschland :(").foregroundColor(.black).font(.system(size: CGFloat(12.0))).fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("\(entry.town):").foregroundColor(.black).font(.system(size: CGFloat(12.0))).fixedSize(horizontal: true, vertical: false)
                            
                            HStack {
                                Text("\(entry.incidency)").foregroundColor(.black).fontWeight(.bold)
                                Circle().foregroundColor(entry.color).frame(width: 15, height: 15)
                            }
                        }
                        
                        if (entry.twoLocations != 0)
                        {
                            Divider().foregroundColor(.black)
                            
                            Text("\(entry.townSearch):").foregroundColor(.black).font(.system(size: CGFloat(12.0))).fixedSize(horizontal: true, vertical: false)
                            
                            HStack {
                                Text("\(entry.incidencySearch)").foregroundColor(.black).fontWeight(.bold)
                                Circle().foregroundColor(entry.colorSearch).frame(width: 15, height: 15)
                            }
                        }
                        Divider().foregroundColor(.black)
                    }
                    
                    Text("Bleiben Sie gesund.").foregroundColor(.black).font(.system(size: CGFloat(12.0))).fixedSize(horizontal: true, vertical: false)
                    
                    Spacer()
                    Spacer()
                }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.white))
    }
}

@main
struct Inzidenz_Widget: Widget {
    let kind: String = "7-Tages-Wert_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Inzidenz_WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Inzidenz_Widget_Previews: PreviewProvider {
    static var previews: some View {
        let town = "Nürnberg"
        let lat = 49.452
        let long = 11.077
        let incidency = 15
        let color = Color.green
        
        Inzidenz_WidgetEntryView(entry: SimpleEntry(date: Date(), longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: 1, townSearch: "Hof", incidencySearch: 75, colorSearch: .blue))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
