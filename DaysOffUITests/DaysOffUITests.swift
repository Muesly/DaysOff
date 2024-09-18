//
//  DaysOffUITests.swift
//  DaysOffUITests
//
//  Created by Tony Short on 14/09/2024.
//

import XCTest

final class DaysOffUITests: XCTestCase {
    static let uiTestingNoAnimationsKey = "UI_TESTING_NO_ANIMATIONS"
    static let uiTestingResetKey = "UI_TESTING_RESET"
    static let uiTestingDateKey = "UI_TESTING_DATE"

    private func resetApp(currentDateStr: String = "16 Sep 2024") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append(Self.uiTestingNoAnimationsKey)
        app.launchArguments.append(Self.uiTestingResetKey)
        app.launchEnvironment[Self.uiTestingDateKey] = currentDateStr
        app.launch()
        return app
    }

    @MainActor
    func test_appInitialView() throws {
        let app = resetApp()

        let navigationTitle = app.navigationBars["Days Off"].staticTexts["Days Off"]
        XCTAssert(navigationTitle.exists)

        let yearSelectorText = app.staticTexts["2024"]
        XCTAssert(yearSelectorText.exists)

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
        XCTAssert(app.staticTexts["Days Reserved: 0.5 days"].exists)

        let daysTakenList = app.collectionViews.firstMatch
        XCTAssert(daysTakenList.staticTexts["This Month"].exists)
        XCTAssert(daysTakenList.staticTexts["Tuesday 17 September 2024 - 0.5 day"].exists)
        XCTAssert(daysTakenList.staticTexts["Monday 16 September 2024 - 1 day"].exists)

        // Check can only add one entry per day by changing a day from half to 1 day
        app.buttons["Take 1 Day"].tap()
        XCTAssert(daysTakenList.staticTexts["Tuesday 17 September 2024 - 1 day"].exists)
        XCTAssert(app.staticTexts["Days Reserved: 1 day"].exists)

        // Swipe to delete
        let entryToDelete = daysTakenList.staticTexts["Tuesday 17 September 2024 - 1 day"]
        entryToDelete.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssert(app.staticTexts["Days Reserved: 0 days"].exists)

        // Restart app without resetting
        app.launchArguments.removeAll()
        app.launch()

        // Check it remembers days
        XCTAssert(app.staticTexts["Days Left: 25 days"].exists)
    }

    @MainActor
    func test_addingIntoDifferentSections() throws {
        let app = resetApp()

        app.datePickers.firstMatch.buttons["Date Picker"].tap()
        sleep(1)
        app.buttons["Tuesday 17 September"].tap()
        app.buttons["PopoverDismissRegion"].tap()
        app.buttons["Take 1 Day"].tap()

        app.datePickers.firstMatch.buttons["Date Picker"].tap()
        app.changeMonth(forwards: false, times: 9)
        app.buttons["Friday 29 December"].tap()
        app.buttons["PopoverDismissRegion"].tap()
        app.buttons["Take 1 Day"].tap()

        app.datePickers.firstMatch.buttons["Date Picker"].tap()
        app.changeMonth(forwards: true, times: 7)
        app.buttons["Wednesday 31 July"].tap()
        app.buttons["PopoverDismissRegion"].tap()
        app.buttons["Take 1 Day"].tap()

        app.datePickers.firstMatch.buttons["Date Picker"].tap()
        app.changeMonth(forwards: true)
        app.buttons["Thursday 8 August"].tap()
        app.buttons["PopoverDismissRegion"].tap()
        app.buttons["Take 1 Day"].tap()

        app.datePickers.firstMatch.buttons["Date Picker"].tap()
        app.changeMonth(forwards: true, times: 2)
        app.buttons["Tuesday 1 October"].tap()
        app.buttons["PopoverDismissRegion"].tap()
        app.buttons["Take 1 Day"].tap()

        app.datePickers.firstMatch.buttons["Date Picker"].tap()
        app.changeMonth(forwards: true, times: 3)
        app.buttons["Thursday 2 January"].tap()
        app.buttons["PopoverDismissRegion"].tap()
        app.buttons["Take 1 Day"].tap()

        let daysTakenList = app.collectionViews.firstMatch
        XCTAssert(daysTakenList.staticTexts["Future Months"].exists)
        XCTAssert(daysTakenList.staticTexts["Tuesday 1 October 2024 - 1 day"].exists)

        XCTAssert(daysTakenList.staticTexts["This Month"].exists)
        XCTAssert(daysTakenList.staticTexts["Tuesday 17 September 2024 - 1 day"].exists)

        XCTAssert(daysTakenList.staticTexts["Last Month"].exists)
        XCTAssert(daysTakenList.staticTexts["Thursday 8 August 2024 - 1 day"].exists)

        XCTAssert(daysTakenList.staticTexts["Previous Months"].exists)
        XCTAssert(daysTakenList.staticTexts["Wednesday 31 July 2024 - 1 day"].exists)

        XCTAssert(app.staticTexts["Starting Total: 26 days"].exists)
        XCTAssert(app.staticTexts["Days Taken So Far: 2 days"].exists)
        XCTAssert(app.staticTexts["Days Left: 24 days"].exists)
        XCTAssert(app.staticTexts["Days Reserved: 2 days"].exists)
        XCTAssert(app.staticTexts["Days To Plan: 22 days"].exists)
    }

    @MainActor
    func test_changingYears() throws {
        let app = resetApp()

        let startingYearText = app.staticTexts["2024"]
        XCTAssert(startingYearText.exists)

        app.buttons["Next Year"].tap()
        let nextYearText = app.staticTexts["2025"]
        XCTAssert(nextYearText.exists)

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
