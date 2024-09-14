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

    static let uiTestingNoAnimationsKey = "UI_TESTING_NO_ANIMATIONS"
    static let uiTestingResetKey = "UI_TESTING_RESET"
    static let uiTestingDateKey = "UI_TESTING_DATE"

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
        ProcessInfo.processInfo.arguments.contains(Self.uiTestingResetKey)
    }

    private static var disableAnimations: Bool {
        ProcessInfo.processInfo.arguments.contains(Self.uiTestingNoAnimationsKey)
    }

    private static var overriddenDate: Date? {
        if let dateStr = ProcessInfo.processInfo.environment[uiTestingDateKey] {
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
