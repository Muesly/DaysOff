//
//  DaysOffAppDelegate.swift
//  DaysOff
//
//  Created by Tony Short on 14/09/2024.
//

import SwiftUI
import SwiftData
import UIKit

class DaysOffAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = DaysOffSceneDelegate.self
        return sceneConfig
    }
}

class DaysOffSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let sharedModelContainer: ModelContainer
    private let currentDate: Date

    override init() {
        self.sharedModelContainer = Self.createSharedModelContainer()
        self.currentDate = Self.overriddenDate ?? Date()
        super.init()
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
            let schema = Schema([DayOffModel.self])
            return try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema)])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        if Self.isResettingApplication {
            try? sharedModelContainer.mainContext.delete(model: DayOffModel.self)
        }

        if Self.seedData {
            seedData()
        }

        if Self.disableAnimations {
            UIView.setAnimationsEnabled(false)
        }

        let contentView = DaysOffView(currentDate: currentDate).modelContainer(sharedModelContainer)
        window.rootViewController = UIHostingController(rootView: contentView)
        window.makeKeyAndVisible()
    }
}
