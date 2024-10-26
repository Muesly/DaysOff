//
//  DaysOffUITests.swift
//  DaysOffUITests
//
//  Created by Tony Short on 14/09/2024.
//

import XCTest

struct AppProvider {
    static func setupApp(currentDateStr: String = "16 Sep 2024",
                          reset: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append(UITestingKeys.noAnimationsKey.rawValue)
        app.launchEnvironment[UITestingKeys.dateKey.rawValue] = currentDateStr
        if reset {
            app.launchArguments.append(UITestingKeys.resetKey.rawValue)
        }
        app.launch()
        return app
    }
}

class DaysOffUITests: XCTestCase {
    @MainActor
    func test_smokeTest() {
        // Setup app
        var app = AppProvider.setupApp()

        // Expand stats
        app.buttons["Expand Button"].tap()

        // Check basic header and stats are there
        XCTAssert(app.navigationBars["Days Off"].staticTexts["Days Off"].exists)
        XCTAssert(app.staticTexts["2024"].exists)
        XCTAssert(app.staticTexts["Days Left: 31 days"].exists)
        XCTAssert(app.staticTexts["Days Reserved: 0 days"].exists)

        // Take a day (checking headers and day count for month)
        app.buttons["Take Day"].tap()

        XCTAssert(app.staticTexts["Sep 24"].exists)
        ["M", "T", "W", "T", "F", "S", "S"].forEach {
            XCTAssert(app.staticTexts[$0].exists)
        }
        for i in 1...30 {
            XCTAssert(app.buttons["\(i)"].exists)
        }
        XCTAssertFalse(app.buttons["31"].exists)

        app.buttons["16"].tap()
        app.buttons["Save"].tap()
        XCTAssert(app.staticTexts["Days Left: 30 days"].exists)

        // Take a half day
        app.buttons["Take Day"].tap()
        app.buttons["13"].tap()
        app.buttons["13"].tap()
        app.buttons["Save"].tap()
        XCTAssert(app.staticTexts["Days Left: 29.5 days"].exists)

        // Take a day but cancel
        app.buttons["Take Day"].tap()
        app.buttons["12"].tap()
        app.buttons["Cancel"].tap()
        XCTAssert(app.staticTexts["Days Left: 29.5 days"].exists)

        // Take a range next month
        app.buttons["Take Day"].tap()
        app.buttons["Previous Month"].tap()
        app.buttons["Next Month"].tap()
        app.buttons["Next Month"].tap()
        XCTAssert(app.staticTexts["Oct 24"].exists)
        for i in 1...31 {
            XCTAssert(app.buttons["\(i)"].exists)
        }

        // Range
        app.buttons["2"].tap()
        app.buttons["3"].tap()
        app.buttons["3"].tap()  // Tries out trailing triangle
        app.buttons["Save"].tap()

        // Check days taken
        let daysTakenList = app.collectionViews.firstMatch
        XCTAssert(daysTakenList.staticTexts["This Month"].exists)
        XCTAssert(daysTakenList.staticTexts["Fri 13th Sep 24 - 0.5 day"].exists)
        XCTAssert(daysTakenList.staticTexts["Mon 16th Sep 24 - 1 day"].exists)
        XCTAssert(daysTakenList.staticTexts["Future Months"].exists)
        XCTAssert(daysTakenList.staticTexts["Wed 2nd Oct 24 - 1 day"].exists)
        XCTAssert(daysTakenList.staticTexts["Thu 3rd Oct 24 - 0.5 day"].exists)
        XCTAssert(app.staticTexts["Days To Plan: 28 days"].exists)

        // Swipe to delete
        let entryToDelete = daysTakenList.staticTexts["Fri 13th Sep 24 - 0.5 day"]
        entryToDelete.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssert(app.staticTexts["Days To Plan: 28.5 days"].exists)

        // Check it remembers days
        app = AppProvider.setupApp(reset: false)
        app.buttons["Expand Button"].tap()
        XCTAssert(app.staticTexts["Days To Plan: 28.5 days"].exists)

        // Go to next year then back a year
        app.buttons["Next Year"].tap()
        app.buttons["Previous Year"].tap()
        XCTAssert(app.staticTexts["2024"].exists)

        // Change entitled days to 10, but cancel
        app.buttons["Edit Starting Number Of Days"].tap()
        let entitledTextField = app.textFields["Entitled Days"]
        entitledTextField.tap()
        entitledTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        entitledTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        entitledTextField.typeText("10")
        app.buttons["Cancel"].tap()
        XCTAssert(app.staticTexts["Days To Plan: 28.5 days"].exists)

        // Change entitled days to 0
        app.buttons["Edit Starting Number Of Days"].tap()
        entitledTextField.tap()
        entitledTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        entitledTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        entitledTextField.typeText("0")

        // When I set K days to 2.5
        let kDaysTextField = app.textFields["K Days"]
        kDaysTextField.tap()
        kDaysTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        kDaysTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        kDaysTextField.typeText("2.5")
        app.buttons["Save"].tap()

        // Then there's a new starting total
        XCTAssert(app.staticTexts["Starting Total: 2.5 days"].exists)
    }
}
