//
//  DaysOffUITests.swift
//  DaysOffUITests
//
//  Created by Tony Short on 14/09/2024.
//

import XCTest

final class DaysOffUITests: XCTestCase {

    @MainActor
    func test_appInitialView() throws {
        let app = XCUIApplication()
        app.launch()

        let navigationTitle = app.navigationBars["Days Off in 2024"].staticTexts["Days Off in 2024"]
        XCTAssert(navigationTitle.exists)

        let daysOffText = app.staticTexts["Days Left: 26 days"]
        XCTAssert(daysOffText.exists)
    }
}
