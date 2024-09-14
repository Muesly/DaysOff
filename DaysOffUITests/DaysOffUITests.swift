//
//  DaysOffUITests.swift
//  DaysOffUITests
//
//  Created by Tony Short on 14/09/2024.
//

import XCTest

final class DaysOffUITests: XCTestCase {
    static let uiTestingResetKey = "UI_TESTING_RESET"
    static let uiTestingDateKey = "UI_TESTING_DATE"

    private func resetApp(currentDateStr: String = "16 Sep 2024") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append(Self.uiTestingResetKey)
        app.launchEnvironment[Self.uiTestingDateKey] = currentDateStr
        app.launch()
        return app
    }

    @MainActor
    func test_appInitialView() throws {
        let app = resetApp()

        let navigationTitle = app.navigationBars["Days Off in 2024"].staticTexts["Days Off in 2024"]
        XCTAssert(navigationTitle.exists)

        let daysOffText = app.staticTexts["Days Left: 26 days"]
        XCTAssert(daysOffText.exists)
    }

    @MainActor
    func test_appTakeDayAndThenHalfDay_andIsRemembered() throws {
        let app = resetApp()

        XCTAssert(app.staticTexts["Days Left: 26 days"].exists)

        app.buttons["Take 1 Day"].tap()
        XCTAssert(app.staticTexts["Days Left: 25 days"].exists)

        app.datePickers.firstMatch.buttons["Date Picker"].tap()
        app.buttons["Tuesday 17 September"].tap()
        app.buttons["PopoverDismissRegion"].tap()

        app.buttons["Take 1/2 Day"].tap()
        XCTAssert(app.staticTexts["Days Left: 24.5 days"].exists)

        let daysTakenList = app.collectionViews.firstMatch
        XCTAssert(daysTakenList.staticTexts["This Month"].exists)
        XCTAssert(daysTakenList.staticTexts["Tuesday 17 September 2024 - 0.5 day"].exists)
        XCTAssert(daysTakenList.staticTexts["Monday 16 September 2024 - 1 day"].exists)

        // Check can only add one entry per day by changing a day from half to 1 day
        app.buttons["Take 1 Day"].tap()
        XCTAssert(daysTakenList.staticTexts["Tuesday 17 September 2024 - 1 day"].exists)
        XCTAssert(app.staticTexts["Days Left: 24 days"].exists)

        // Restart app without resetting
        app.launchArguments.removeAll()
        app.launch()

        // Check it remembers days
        XCTAssert(app.staticTexts["Days Left: 24 days"].exists)
    }
}
