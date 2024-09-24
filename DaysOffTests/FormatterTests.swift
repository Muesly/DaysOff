//
//  FormatterTests.swift
//  DaysOffTests
//
//  Created by Tony Short on 14/09/2024.
//

import Foundation
import SwiftUI
import Testing

@testable import DaysOff

struct FormatterTests {
    @Test func dateFormatter() async {
        let dc = DateComponents(year: 2024, month: 1, day: 1)
        let date = Calendar.current.date(from: dc)!
        #expect(Formatters.dateFormatter.string(from: date) == "Monday 1 January 2024")
    }
}
