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

        let initialDaysOffText = app.staticTexts["Days Left: 26 days"]
        XCTAssert(initialDaysOffText.exists)

        let takeDayButton = app.buttons["Take 1 Day"]
        takeDayButton.tap()

        let firstModificationText = app.staticTexts["Days Left: 25 days"]
        XCTAssert(firstModificationText.exists)

        let dateSelectorButton = app.datePickers.firstMatch.buttons["Date Picker"]
        dateSelectorButton.tap()

        let nextDateButton = app.buttons["Tuesday 17 September"]
        nextDateButton.tap()

        app.buttons["PopoverDismissRegion"].tap()

        let takeHalfDayButton = app.buttons["Take 1/2 Day"]
        takeHalfDayButton.tap()

        let secondModificationText = app.staticTexts["Days Left: 24.5 days"]
        XCTAssert(secondModificationText.exists)

        let daysTakenList = app.collectionViews.firstMatch
        XCTAssert(daysTakenList.staticTexts["DAYS TAKEN"].exists)
        XCTAssert(daysTakenList.staticTexts["Tuesday 17 September 2024 - 0.5 day"].exists)
        XCTAssert(daysTakenList.staticTexts["Monday 16 September 2024 - 1 day"].exists)

        app.launchArguments.removeAll()
        app.launch()

        let rememberedDaysOffText = app.staticTexts["Days Left: 24.5 days"]
        XCTAssert(rememberedDaysOffText.exists)
    }
}
