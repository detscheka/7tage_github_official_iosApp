//
//  ContentView.swift
//  Shared
//
//  Created by Tschekalinskij, Alexander on 3/7/21.
//

import SwiftUI
import CoreData
import CoreLocation
import WidgetKit

struct WhatsNew: View {

    // Variable to Dismiss Modal
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {

        Spacer()
        
        VStack (alignment: .leading) {
            HStack {
                Spacer()
                Text("Danke, dass du meine App nutzt!\nWas ist neu?").font(.system(size: CGFloat(30.0)))
                Spacer()
            }
            
            Spacer()
            
            VStack (alignment: .leading)  {
                Text("• Die App funktioniert nun stabiler und schneller.").font(.system(size: CGFloat(fontSizeWelcomeScreen)))
                Text("• Abstürze durch Benutzen der App außerhalb von Deutschland wurden behoben.").font(.system(size: CGFloat(fontSizeWelcomeScreen)))
                Text("• Die App kann nun auch außerhalb Deutschlands benutzt werden, allerdings nur für eine manuelle Suche von Orten in Deutschland.").font(.system(size: CGFloat(fontSizeWelcomeScreen)))
                Text("• App und Widget können nun auch ohne Standortfreigabe arbeiten.\nEs wird der Wert aus der manuellen Suche angezeigt.").font(.system(size: CGFloat(fontSizeWelcomeScreen)))
                Text("• Der Ort aus der manuellen Suche wird gespeichert.").font(.system(size: CGFloat(fontSizeWelcomeScreen)))
                Text("\n")
                Text("• Denke daran, dein GPS anzuschalten, um den aktuellen Wert an deinem Standort zu erhalten.\nOhne GPS kannst du nach Werten an anderen Orten suchen und diese im Widget anzeigen lassen.").font(.system(size: CGFloat(fontSizeWelcomeScreen))).fontWeight(.bold)
            }.offset(x: 5, y: 0)
            
            Spacer()

            HStack {
                Spacer()
                
                Button(action: { self.presentationMode.wrappedValue.dismiss() }, label: {
                    Text("Verstanden")
                }).foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(8)
                
                Spacer()
            }
            Spacer()
        }
    }
    
    let screenWidth = UIScreen.screenWidth
    let screenHeight = UIScreen.screenHeight
    var fontSizeWelcomeScreen: Double { return(getWelcomeScreenFontSize()) }
    func getWelcomeScreenFontSize() -> Double
        {
    let screenHeightTmp = screenHeight
    let screenWidthTmp = screenWidth
    var font = 15.0
    switch( screenHeightTmp, screenWidthTmp )
            {
    case (926, 428):
    /* iPhone 12 Pro Max*/
                    font = 17.0
    case (812, 375):
    /* iPhone 12 mini */
                    font = 16.0
    case (667, 375):
    /* iPhone SE (2nd generation) || iPhone 8 */
                    font = 15.0
    case (568, 320):
    /* iPod touch (7th generation) */
                    font = 13.0
    case (844, 390):
    /* iPhone 12 Pro / iPhone 12 */
                    font = 17.0
    case (896, 414):
    /* iPhone 11 Pro Max / iPhone 11 */
                    font = 17.0
    case (812, 375):
    /* iPhone 11 Pro */
                    font = 15.0
    case (736, 414):
    /* iPhone 8 Plus */
                    font = 16.0
    case (1366, 1024):
    /* iPad Pro (12.9-inch) (4th generation) */
                    font = 18.0
    case (1194, 834):
    /* iPad Pro (11 -inch) (2nd generation) */
                    font = 22.0
    case (1024, 768):
    /* iPad Pro (9.7 -inch) */
                    font = 22.0
    case (1180, 820):
    /* iPad Air (4th generation) */
                    font = 22.0
    case (1080, 810):
    /* iPad (8th generation) */
                    font = 22.0
    default:
    print("Unknown device")
                    font = 15.0
            }
    return font
        }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var locationViewModel = LocationViewModel()
    
    // Variable to trigger WhatsNew Screen
    @State private var showWhatsNew = false

    let smallSymbolImage = UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
    
    // Get current Version of the App
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        return version
    }
    
    // Check if app if app has been started after update
    func checkForUpdate() {
        let version = getCurrentAppVersion()
        let savedVersion = UserDefaults.standard.string(forKey: "savedVersion")

        if savedVersion == version {
            print("App is up to date!")
        } else {
            // Toogle to show WhatsNew Screen as Modal
            self.showWhatsNew.toggle()
            UserDefaults.standard.set(version, forKey: "savedVersion")
        }
    }
    
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
    
    struct FilledButton: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .foregroundColor(configuration.isPressed ? .gray : .white)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(10)
        }
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var latitude: Double  { return(locationViewModel.userLatitude ) }
    var longitude: Double { return(locationViewModel.userLongitude ) }
    var town: String { return(locationViewModel.userTown) }
    var incidency: Int { return(locationViewModel.incidency) }
    var color: UIColor { return(locationViewModel.color) }

    @State var textPLZ: Binding<String> = .constant("")
    @State var name: String = ""
    
    @State private var showDetails = false
    
    
    @State var townSearch: String = ""
    @State var incidencySearch: Int = 0
    @State var colorSearch: UIColor = UIColor.init(red: 159/255, green: 252/255, blue: 172/255, alpha: 1)
    
    @State var searchLat: Double = 0.0
    @State var searchLong: Double = 0.0
    
    var body: some View {
        
        Spacer()
        
        VStack (alignment: .center) {
            Text("7-Tages-Wert für").font(.system(size: CGFloat(30.0)))
            .sheet(isPresented: $showWhatsNew, content: { WhatsNew() }) // Show Sheet
            .onAppear(perform: checkForUpdate) // Run checkForUpdate when View Appears
            .onAppear(perform: loadLastUserSearch) // Load last location user searched for
            
            if (locationViewModel.userTown == "")
            {
                HStack {
                    Spacer()
                    Text("GPS nicht verfügbar oder Ort außerhalb von Deutschland :(").font(.system(size: CGFloat(20.0))).fontWeight(.bold)
                    Spacer()
                }
                
            } else {
                HStack {
                    Image.init(uiImage: self.smallSymbolImage!)
                    Text("\(locationViewModel.userTown)").font(.system(size: CGFloat(30.0)))
                }
                
                HStack {
                    Text("\(locationViewModel.incidency)").foregroundColor(.black).fontWeight(.bold).font(.system(size: CGFloat(40.0)))
                    Circle().foregroundColor(Color(locationViewModel.color)).frame(width: 30, height: 30)
                }
            }

            Divider().foregroundColor(.black)
            
            Spacer()
            
            Text("Wert nach Ort").font(.system(size: CGFloat(30.0)))
            VStack (alignment: .center, spacing: 30)  {
                TextField("Ortsname eingeben...", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 200, height: 30)
                
                HStack
                {
                    Button("Wert anzeigen") {
                            hideKeyboard()
                        
                        if (name != "")
                        {
                            showDetails = true
                            
                            getCoordinateFrom(address: name) { coordinate, error in
                                guard let coordinate = coordinate, error == nil else { return }
                                // don't forget to update the UI from the main thread
                                DispatchQueue.main.async {
                                    self.searchLat = coordinate.latitude
                                    self.searchLong = coordinate.longitude
                                    print(name, "Location:", coordinate) // Rio de Janeiro, Brazil Location: CLLocationCoordinate2D(latitude: -22.9108638, longitude: -43.2045436)
                                    getData(userLatitude: coordinate.latitude, userLongitude: coordinate.longitude)
                                    saveUserSearchCoordinates(lat: coordinate.latitude, long: coordinate.longitude)
                                }
                            }
                        } else {
                            self.showAlertTextEmpty = true
                        }
                        
                        }.buttonStyle(FilledButton())
                    .alert(isPresented: $showAlertTextEmpty, content: { () -> Alert in
                        Alert(title: Text("Sorry :("), message: Text("Bitte gebe einen Ortsnamen ein, z.B. 'München' oder 'Frankfurt Main'."), dismissButton: .default(Text("Verstanden")))
                    })
                            
            
                    Button("Zu Widget hinzufügen") {
                        if (name != "")
                        {
                            writeDefaultDouble(key: "userSearchLong", val: self.searchLong)
                            writeDefaultDouble(key: "userSearchLat", val: self.searchLat)
                            showAlertAddToWidget = true
                            
                            WidgetCenter.shared.reloadAllTimelines()
                        } else {
                            self.showAlertTextEmpty = true
                        }

                        }.buttonStyle(FilledButton())
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Sorry :("), message: Text("Entweder konnte dein Ort nicht gefunden werden oder er befindet sich außerhalb Deutschlands. Bitte versuche es erneut."), dismissButton: .default(Text("Verstanden")))
                    }
                    .alert(isPresented: $showAlertAddToWidget) {
                        Alert(title: Text("Ort hinzugefügt."), message: Text("Es kann ein Paar Minuten dauern, bis der neue Ort im Widget erscheint."), dismissButton: .default(Text("Verstanden")))
                    }
                }

                
                if showDetails {
                    Text("7-Tages-Wert für").font(.system(size: CGFloat(30.0)))
                    Text("\(self.townSearch)").font(.system(size: CGFloat(30.0)))
                    
                    HStack {
                        Text("\(incidencySearch)").foregroundColor(.black).fontWeight(.bold).font(.system(size: CGFloat(40.0)))
                        Circle().foregroundColor(Color(colorSearch)).frame(width: 30, height: 30)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    func loadLastUserSearch()
    {
        let userSearchLat = readFromDefaultDouble(key: "userSearchLat", defVal: 0)
        let userSearchLong = readFromDefaultDouble(key: "userSearchLong", defVal: 0)
        
        if ((userSearchLat != 0) && (userSearchLong != 0))
        {
            getData(userLatitude: userSearchLat, userLongitude: userSearchLong)
            showDetails = true
        }
    }
    
    func saveUserSearchCoordinates(lat: Double, long: Double)
    {
        writeDefaultDouble(key: "userSearchLat", val: lat)
        writeDefaultDouble(key: "userSearchLong", val: long)
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
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
    
    func writeDefaultDouble(key : String, val : Double)
    {
        if let userDefaults = UserDefaults(suiteName: "group.BAgames.incidency") {
            userDefaults.set(val, forKey: key)
        } else {
            print("Error writing default integer for key \(key)!")
        }
    }
    
    @State private var showAlert = false;
    @State private var showAlertTextEmpty = false;
    @State private var showAlertAddToWidget = false;
    
    func getData(userLatitude: Double, userLongitude: Double)
    {
        let lat3 = String(format: "%.3f", userLatitude)
        let long3 = String(format: "%.3f", userLongitude)
        var incidency = 0
        var color = UIColor.init(red: 159/255, green: 252/255, blue: 172/255, alpha: 1)
        
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
                        self.showAlert = true
                        return
                    }
                    
                    incid = floor(incid!)
                    print(incid)
                    
                    let landkreisVal = array[array.count - 4]
                    let arrLandkreis = landkreisVal.components(separatedBy: ",")
                    var landkreis = arrLandkreis[0]
                    print(landkreis)
                    landkreis = landkreis.replacingOccurrences(of: "\"", with: "")
                    
                    self.townSearch = landkreis
                    self.incidencySearch = Int(incid!)
                    
                    DispatchQueue.main.async {
                        self.townSearch = landkreis
                        self.incidencySearch = Int(incid!)
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
                    
                    if ((incidency > 300))
                    {
                        color = UIColor.init(red: 20/255, green: 5/255, blue: 1/255, alpha: 1)
                    }
                    
                    self.colorSearch = color
                    DispatchQueue.main.async {
                        self.colorSearch = color
                    }
                 }
               }
           }.resume()
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
