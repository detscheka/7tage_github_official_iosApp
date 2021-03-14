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
    
    let smallSymbolImage = UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
    
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
        let incidency = 15
        let color = Color.green
        
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
        
        return SimpleEntry(date: Date(), longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: 0, townSearch: "", incidencySearch: 75, colorSearch: Color.init(.sRGB, red: 191/255, green: 71/255, blue: 42/255, opacity: 1), fontSize: 10.0, fontSizeLocationImage: 10.0, userLocationToggle: 1)
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
    
    func readFromDefaultInt(key : String, defVal : Int) -> Int
    {
        if let userDefaults = UserDefaults(suiteName: "group.BAgames.incidency") {
            let val = userDefaults.integer(forKey: key)
            return val
        } else {
            return defVal
        }
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        var town = "Nürnberg"
        var lat = 49.452
        var long = 11.077
        let incidency = 15
        let color = Color.green
        
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
        
        let entry = SimpleEntry(date: Date(), longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: 0, townSearch: "", incidencySearch: 75, colorSearch: Color.init(.sRGB, red: 191/255, green: 71/255, blue: 42/255, opacity: 1), fontSize: 10.0, fontSizeLocationImage: 10.0, userLocationToggle: 1)
        completion(entry)
    }
    
    func getWelcomeScreenFontSize() -> (CGFloat, CGFloat)
    {
        let screenHeight = Int(UIScreen.main.bounds.height)
        let screenWidth  = Int(UIScreen.main.bounds.width)
        
        let screenHeightTmp = screenHeight
        let screenWidthTmp = screenWidth
        var font = 10.0
        var fontLocationImage = 10.0
        
#if DEBUG_PRINT
        print(screenHeightTmp)
        print(screenWidthTmp)
#endif
        
        switch( screenHeightTmp, screenWidthTmp )
        {
            case (926, 428):
            /* iPhone 12 Pro Max*/
                font = 10.0
                fontLocationImage = 10.0
            case (812, 375):
            /* iPhone 12 mini */
                font = 9.0
                fontLocationImage = 9.0
            case (667, 375):
            /* iPhone SE (2nd generation) || iPhone 8 */
                font = 8.0
                fontLocationImage = 8.0
            case (568, 320):
            /* iPod touch (7th generation) || iPhone SE (1st generation) */
                font = 7.0
                fontLocationImage = 8.0
            case (844, 390):
            /* iPhone 12 Pro / iPhone 12 */
                font = 9.0
                fontLocationImage = 9.0
            case (896, 414):
            /* iPhone 11 Pro Max / iPhone 11 */
                font = 10.0
                fontLocationImage = 10.0
            case (812, 375):
            /* iPhone 11 Pro */
                font = 10.0
                fontLocationImage = 10.0
            case (736, 414):
            /* iPhone 8 Plus */
                font = 10.0
                fontLocationImage = 10.0
            case (1366, 1024):
            /* iPad Pro (12.9-inch) (4th generation) */
                font = 10.0
                fontLocationImage = 10.0
            case (1194, 834):
            /* iPad Pro (11 -inch) (2nd generation) */
                font = 10.0
                fontLocationImage = 10.0
            case (1024, 768):
            /* iPad Pro (9.7 -inch) */
                font = 10.0
                fontLocationImage = 10.0
            case (1180, 820):
            /* iPad Air (4th generation) */
                font = 10.0
                fontLocationImage = 10.0
            case (1080, 810):
            /* iPad (8th generation) */
                font = 10.0
                fontLocationImage = 10.0
            default:
            print("Unknown device")
                font = 10.0
                fontLocationImage = 10.0
        }
        
        return (CGFloat(font), CGFloat(fontLocationImage))
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
        
        let userSearchLong = readFromDefaultDouble(key: "userSearchLong", defVal: 0.0)
        let userSearchLat = readFromDefaultDouble(key: "userSearchLat", defVal: 0.0)
        let userLocationToggle = readFromDefaultInt(key: "locationToggle", defVal: 1)
        
        /* First load the user saved data */
        
        print("Color before if")
        print(color)
        print(incidency)
        
        let (fontSize, fontSizeLocationImage) = getWelcomeScreenFontSize()
        
        if ((userSearchLong != 0) && (userSearchLat != 0))
        {
            /* Display also second town data */
            two = 1
            
            let lat3user = String(format: "%.3f", userSearchLat)
            let long3user = String(format: "%.3f", userSearchLong)
                
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
                            
                            DispatchQueue.main.async {
                                townSearch = landkreis
                                incidencySearch = Int(ceil(incid!))
                            }
                            
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
                        
                            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
                            if ((status == .denied) || (status == .restricted) || (status == .notDetermined))
                            {
                                print("No authorization. Quitting with empty timeline.")
                                
                                let entry = SimpleEntry(date: currentDate, longitude: Float(long), latitude: Float(lat), town: "", incidency: Int(incidency), color: color, twoLocations: two, townSearch: townSearch, incidencySearch: incidencySearch, colorSearch: colorSearch, fontSize: CGFloat(fontSize), fontSizeLocationImage: fontSizeLocationImage, userLocationToggle: Int(userLocationToggle))

                                let timeline = Timeline(entries: [entry], policy: .atEnd)
                                completion(timeline)
                            }
                         }
                       }
                   }.resume()
                }
        } else {
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if ((status == .denied) || (status == .restricted) || (status == .notDetermined))
            {
                print("No authorization. Quitting with empty timeline.")
                
                let entry = SimpleEntry(date: currentDate, longitude: Float(long), latitude: Float(lat), town: "", incidency: Int(incidency), color: color, twoLocations: two, townSearch: townSearch, incidencySearch: incidencySearch, colorSearch: colorSearch, fontSize: CGFloat(fontSize), fontSizeLocationImage: fontSizeLocationImage, userLocationToggle: Int(userLocationToggle))

                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
        
        print("Loading normal data...")
        
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
                            print(incid ?? "incidency not found...")
                            
                            let landkreisVal = array[array.count - 4]
                            let arrLandkreis = landkreisVal.components(separatedBy: ",")
                            var landkreis = arrLandkreis[0]
                            print(landkreis)
                            landkreis = landkreis.replacingOccurrences(of: "\"", with: "")
                            town = landkreis
                            
                            incidency = Int(ceil(incid!))
                            
                            DispatchQueue.main.async {
                                town = landkreis
                                incidency = Int(ceil(incid!))
                            }
                            
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
                            
                            print("User saved data:")
                            print(townSearch)
                            print(incidencySearch)
                            print(colorSearch)

                            let entry = SimpleEntry(date: currentDate, longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: two, townSearch: townSearch, incidencySearch: incidencySearch, colorSearch: colorSearch, fontSize: CGFloat(fontSize), fontSizeLocationImage: fontSizeLocationImage, userLocationToggle: Int(userLocationToggle))

                            let timeline = Timeline(entries: [entry], policy: .atEnd)
                            completion(timeline)
                         }
                       }
                   }.resume()
                }
            }
        })
        
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
    
    let fontSize: CGFloat
    let fontSizeLocationImage: CGFloat
    let userLocationToggle: Int
}

struct Inzidenz_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack (alignment: .center, spacing: 5) {
            Spacer()
            
                VStack (alignment: .center, spacing: 2) {
                    VStack (alignment: .center, spacing: 5) {
                        Spacer()
                        Text("7-Tages-Wert").foregroundColor(.black).font(.system(size: entry.fontSize))
                        
                        Divider().foregroundColor(.black)
                        
                        if (entry.town == "")
                        {
                            Text("Daten werden geladen...").foregroundColor(.black).font(.system(size: entry.fontSize + 2.0)).fixedSize(horizontal: false, vertical: true)
                        } else if (entry.userLocationToggle == 0) {
                            /* Nothing to print here, since user deactivated location printing in widget */
                        } else {
                            HStack {
                                Image.init(systemName: "location").foregroundColor(.black).font(.system(size: entry.fontSizeLocationImage))
                                Text("\(entry.town):").foregroundColor(.black).font(.system(size: entry.fontSize + 2.0)).fixedSize(horizontal: true, vertical: false)
                            }
                            
                            HStack {
                                Text("\(entry.incidency)").foregroundColor(.black).fontWeight(.bold)
                                Circle().foregroundColor(entry.color).frame(width: 15, height: 15)
                            }
                        }
                        
                        if (entry.twoLocations != 0 && entry.townSearch != "")
                        {
                            if (entry.userLocationToggle == 1)
                            {
                                Divider().foregroundColor(.black)
                            }
                            
                            Text("\(entry.townSearch):").foregroundColor(.black).font(.system(size: entry.fontSize + 2.0)).fixedSize(horizontal: true, vertical: false)
                            
                            HStack {
                                Text("\(entry.incidencySearch)").foregroundColor(.black).fontWeight(.bold)
                                Circle().foregroundColor(entry.colorSearch).frame(width: 15, height: 15)
                            }
                        }
                        Divider().foregroundColor(.black)
                    }
                    
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
        .configurationDisplayName("7-Tage Widget")
        .description("Dieses Widget zeigt den aktuellen 7-Tage-Wert für deinen aktuellen Standort und für einen weiteren Ort deiner Wahl.")
    }
}

struct Inzidenz_Widget_Previews: PreviewProvider {
    static var previews: some View {
        let town = "Nürnberg"
        let lat = 49.452
        let long = 11.077
        let incidency = 15
        let color = Color.green
        
        Inzidenz_WidgetEntryView(entry: SimpleEntry(date: Date(), longitude: Float(long), latitude: Float(lat), town: town, incidency: Int(incidency), color: color, twoLocations: 1, townSearch: "Hof", incidencySearch: 75, colorSearch: .blue, fontSize: 10.0, fontSizeLocationImage: 10.0, userLocationToggle: 1))
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
