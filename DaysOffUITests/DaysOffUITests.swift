//
//  DaysOffUITests.swift
//  DaysOffUITests
//
//  Created by Tony Short on 14/09/2024.
//

import XCTest

struct AppProvider {
    static func setupApp(currentDateStr: String = "16 Sep 2024",
                          seed: Bool = false,
                          reset: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append(UITestingKeys.noAnimationsKey.rawValue)
        app.launchEnvironment[UITestingKeys.dateKey.rawValue] = currentDateStr
        if seed {
            app.launchArguments.append(UITestingKeys.seededDataKey.rawValue)
        }
        if reset {
            app.launchArguments.append(UITestingKeys.resetKey.rawValue)
        }
        app.launch()
        return app
    }
}

class DaysOffUITests: XCTestCase {
    @MainActor
    func test_appTakeDayAndThenHalfDay_andIsRemembered() {
        var app = AppProvider.setupApp()

        XCTAssert(app.navigationBars["Days Off"].staticTexts["Days Off"].exists)
        XCTAssert(app.staticTexts["2024"].exists)
        XCTAssert(app.staticTexts["Days Left: 31 days"].exists)
        app.buttons["Expand Button"].tap()

        app.buttons["Take Day"].tap()
        app.buttons["16"].tap()
        app.buttons["Save"].tap()
        XCTAssert(app.staticTexts["Days Left: 30 days"].exists)

        app.buttons["Take Day"].tap()
        app.buttons["17"].tap()
        app.buttons["17"].tap()
        app.buttons["Save"].tap()
        XCTAssert(app.staticTexts["Days Reserved: 0.5 days"].exists)

        let daysTakenList = app.collectionViews.firstMatch
        XCTAssert(daysTakenList.staticTexts["This Month"].exists)
        XCTAssert(daysTakenList.staticTexts["Tuesday 17 September 2024 - 0.5 day"].exists)
        XCTAssert(daysTakenList.staticTexts["Monday 16 September 2024 - 1 day"].exists)

        // Check can only add one entry per day by changing a day from half to 1 day
        app.buttons["Take Day"].tap()
        app.buttons["17"].tap()
        app.buttons["Save"].tap()
        XCTAssert(app.staticTexts["Days Reserved: 1 day"].exists)

        // Swipe to delete
        let entryToDelete = daysTakenList.staticTexts["Tuesday 17 September 2024 - 1 day"]
        entryToDelete.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssert(app.staticTexts["Days Reserved: 0 days"].exists)

        app = AppProvider.setupApp(reset: false)

        // Check it remembers days
        XCTAssert(app.staticTexts["Days Left: 30 days"].exists)
    }

    @MainActor
    func test_changingYears() {
        let app = AppProvider.setupApp(seed: true)
        app.buttons["Expand Button"].tap()

        let startingYearText = app.staticTexts["2024"]
        XCTAssert(startingYearText.exists)

        let daysTakenList = app.collectionViews.firstMatch
        XCTAssertTrue(daysTakenList.staticTexts["Monday 16 September 2024 - 1 day"].exists)
        XCTAssertFalse(daysTakenList.staticTexts["Wednesday 1 January 2025 - 1 day"].exists)

        app.buttons["Next Year"].tap()
        let nextYearText = app.staticTexts["2025"]
        XCTAssert(nextYearText.exists)
        XCTAssertFalse(daysTakenList.staticTexts["Monday 16 September 2024 - 1 day"].exists)
        XCTAssertTrue(daysTakenList.staticTexts["Wednesday 1 January 2025 - 1 day"].exists)
    }

    @MainActor
    func test_changeToEntitledDays() {

        // Given app is started in 2024
        let app = AppProvider.setupApp()
        XCTAssert(app.staticTexts["2024"].exists)
        app.buttons["Expand Button"].tap()

        // Then
        XCTAssert(app.staticTexts["Starting Total: 31 days"].exists)

        // When entitled days is changed to 0
        app.buttons["Edit Starting Number Of Days"].tap()
        let entitledTextField = app.textFields["Entitled Days"]
        entitledTextField.tap()
        entitledTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        entitledTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        entitledTextField.typeText("0")
        app.buttons["Save"].tap()

        // Then
        XCTAssert(app.staticTexts["Starting Total: 5 days"].exists)
    }
}

extension XCUIApplication {
    fileprivate func changeMonth(forwards: Bool, times: Int = 1) {
        for _ in 0..<times {
            self.buttons["\(forwards ? "Next" : "Previous") Month"].tap()
        }
        sleep(1)
    }
}
