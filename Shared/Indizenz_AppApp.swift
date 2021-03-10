//
//  Indizenz_AppApp.swift
//  Shared
//
//  Created by Tschekalinskij, Alexander on 3/7/21.
//

import SwiftUI

@main
struct Indizenz_AppApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
