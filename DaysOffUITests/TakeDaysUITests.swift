//
//  TakeDaysUITests.swift
//  DaysOffUITests
//
//  Created by Tony Short on 14/10/2024.
//

import Foundation

import XCTest

final class TakeDaysUITests: DaysOffUITests {
    @MainActor
    func test_appTakeDay() {
        let app = setupApp()
        app.buttons["Take Day"].tap()
        XCTAssert(app.staticTexts["September 24"].exists)
        ["M", "T", "W", "T", "F", "S", "S"].forEach {
            XCTAssert(app.staticTexts[$0].exists)
        }
        for i in 1...30 {
            XCTAssert(app.buttons["\(i)"].exists)
        }
    }
}
