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
    let currentDate: Date
    static let uiTestingResetKey = "UI_TESTING_RESET"
    static let uiTestingDateKey = "UI_TESTING_DATE"

    init() {
        Self.resetApplication()
        self.currentDate = Self.deriveCurrentDate()
    }

    var body: some Scene {
        WindowGroup {
            DaysOffView(model: DaysOffModel(currentDate: currentDate))
        }
    }

    private static func resetApplication() {
        if ProcessInfo.processInfo.arguments.contains(Self.uiTestingResetKey),
           let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }

    private static func deriveCurrentDate() -> Date {
        if let dateStr = ProcessInfo.processInfo.environment[uiTestingDateKey] {
            let df = DateFormatter()
            df.dateFormat = "dd MMM yyyy"
            if let date = df.date(from: dateStr) {
                return date
            }
        }
        return Date()
    }
}
