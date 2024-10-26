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
        #expect(Formatters.dateFormatter.string(for: date) == "Mon 1st Jan 24")
        #expect(Formatters.dateFormatter.string(for: date.addingTimeInterval(86400)) == "Tue 2nd Jan 24")
        #expect(Formatters.dateFormatter.string(for: date.addingTimeInterval(2 * 86400)) == "Wed 3rd Jan 24")
        #expect(Formatters.dateFormatter.string(for: date.addingTimeInterval(3 * 86400)) == "Thu 4th Jan 24")
    }

    @Test func oneDPFormat() async {
        #expect(Formatters.oneDPFormat.format(1.0) == "1")
        #expect(Formatters.oneDPFormat.format(1.5) == "1.5")
    }

}
