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
        XCTAssert(app.staticTexts["October 24"].exists)
    }
}
