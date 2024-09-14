//
//  DaysOffApp.swift
//  DaysOff
//
//  Created by Tony Short on 14/09/2024.
//

import SwiftUI
import SwiftData

@main
struct DaysOffApp: App {

    init() {
        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            resetApplication()
        }
    }

    var body: some Scene {
        WindowGroup {
            DaysOffView()
        }
    }

    private func resetApplication() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
