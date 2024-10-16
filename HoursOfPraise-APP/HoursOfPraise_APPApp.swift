//
//  HoursOfPraise_APPApp.swift
//  HoursOfPraise-APP
//
//  Created by user on 16/10/2024.
//

import SwiftUI

@main
struct HoursOfPraise_APPApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
