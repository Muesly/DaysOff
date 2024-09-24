//
//  DaysOffApp.swift
//  DaysOff
//
//  Created by Tony Short on 22/09/2024.
//

import Foundation
import SwiftData
import SwiftUI

@main
struct DaysOffApp: App {
    private let sharedModelContainer: ModelContainer
    private let currentDate: Date

    init() {
        self.sharedModelContainer = Self.createSharedModelContainer()
        self.currentDate = Self.overriddenDate ?? Date()

        if Self.isResettingApplication {
            try? sharedModelContainer.mainContext.delete(model: DayOffModel.self)
            try? sharedModelContainer.mainContext.delete(model: YearStartingDaysModel.self)
        }

        if Self.seedData {
            seedData()
        }

        if Self.disableAnimations {
            UIView.setAnimationsEnabled(false)
        }
    }

    var body: some Scene {
        WindowGroup {
            if isProduction {
                DaysOffView(currentDate: currentDate).modelContainer(sharedModelContainer)
            }
        }
    }

    private var isProduction: Bool {
        NSClassFromString("XCTestCase") == nil
    }

    private static var isResettingApplication: Bool {
        ProcessInfo.processInfo.arguments.contains(UITestingKeys.resetKey.rawValue)
    }

    private static var seedData: Bool {
        ProcessInfo.processInfo.arguments.contains(UITestingKeys.seededDataKey.rawValue)
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

    private func seedData() {
        let modelContext = sharedModelContainer.mainContext
        modelContext.insert(DayOffModel(date: currentDate, type: .fullDay))

        let dateComponents = DateComponents(year: 2025, month: 1, day: 1)
        modelContext.insert(DayOffModel(date: Calendar.current.date(from: dateComponents)!, type: .fullDay))
    }


    private static func createSharedModelContainer() -> ModelContainer {
        do {
            let schema = Schema([DayOffModel.self, YearStartingDaysModel.self])
            return try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema)])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

extension ModelContext {
    static var inMemory: ModelContext {
        ModelContext(try! ModelContainer(for: DayOffModel.self, YearStartingDaysModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
    }
}
