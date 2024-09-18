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
    let sharedModelContainer: ModelContainer

    init() {
        self.currentDate = Self.overriddenDate ?? Date()
        self.sharedModelContainer = Self.createSharedModelContainer()

        if Self.isResettingApplication {
            try? sharedModelContainer.mainContext.delete(model: DayOffModel.self)
        }

        if Self.disableAnimations {
            UIView.setAnimationsEnabled(false)
        }
    }

    var body: some Scene {
        WindowGroup {
            DaysOffView(currentDate: currentDate)
        }.modelContainer(sharedModelContainer)
    }

    private static var isResettingApplication: Bool {
        ProcessInfo.processInfo.arguments.contains(UITestingKeys.resetKey.rawValue)
    }

    private static var disableAnimations: Bool {
        ProcessInfo.processInfo.arguments.contains(UITestingKeys.noAnimationsKey.rawValue)
    }

    private static var overriddenDate: Date? {
        if let dateStr = ProcessInfo.processInfo.environment[UITestingKeys.dateKey.rawValue] {
            let df = DateFormatter()
            df.dateFormat = "dd MMM yyyy"
            if let date = df.date(from: dateStr) {
                return date
            }
        }
        return nil
    }

    private static func createSharedModelContainer() -> ModelContainer {
        do {
            let schema = Schema([DayOffModel.self])
            return try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema)])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
