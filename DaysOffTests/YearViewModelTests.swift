//
//  YearViewModelTests.swift
//  DaysOffTests
//
//  Created by Tony Short on 05/10/2024.
//

import Foundation
import Testing

@testable import DaysOff

struct YearViewModelTests {
    @Test func predicates() async throws {
        let currentDate = Calendar.current.date(from: .init(year: 2024, month: 3, day: 1))!
        let subject = YearViewModel(modelContext: .inMemory, currentDate: currentDate)

        let monthPeriod: TimeInterval = 31 * 86400
        let futureMonthDate = currentDate.addingTimeInterval(monthPeriod)
        let nextYearMonthDate = currentDate.addingTimeInterval(12 * monthPeriod)
        let currentMonthDate = currentDate
        let lastMonthDate = currentDate.addingTimeInterval(-1)
        let previousMonthDate = currentDate.addingTimeInterval(-monthPeriod)
        let prevYearMonthDate = currentDate.addingTimeInterval(-12 * monthPeriod)

        let daysOff = [DayOffModel(date: futureMonthDate, type: .fullDay),
                       DayOffModel(date: currentMonthDate, type: .fullDay),
                       DayOffModel(date: lastMonthDate, type: .fullDay),
                       DayOffModel(date: previousMonthDate, type: .fullDay),
                       DayOffModel(date: nextYearMonthDate, type: .fullDay),
                       DayOffModel(date: prevYearMonthDate, type: .fullDay)]
        subject.year = 2024

        #expect(try daysOff.filter(subject.futureDaysPredicate!).map { $0.date } == [futureMonthDate])
        #expect(try daysOff.filter(subject.thisMonthDaysPredicate!).map { $0.date } == [currentMonthDate])
        #expect(try daysOff.filter(subject.lastMonthDaysPredicate!).map { $0.date } == [lastMonthDate])
        #expect(try daysOff.filter(subject.previousDaysPredicate!).map { $0.date } == [previousMonthDate])
    }

    @Test func kDays() throws {
        // Given it's 2023
        let currentDate = Calendar.current.date(from: .init(year: 2023, month: 3, day: 1))!
        let subject = YearViewModel(modelContext: .inMemory, currentDate: currentDate)

        // And we've set entitled Days to 0 for the year
        try subject.updateEntitledDaysForCurrentYear(0)
        try subject.updateStartingKDays(4)
        try subject.updateYear(2023)

        #expect(subject.kDays == 4)
        #expect(subject.numDaysToTake == 4)

        // And we've taken one day off in 2023
        let lastYearDayOff = currentDate
        let daysOff = [DayOffModel(date: lastYearDayOff, type: .fullDay)]
        subject.daysOff = daysOff

        // Change to 2024
        try subject.updateYear(2024)
        #expect(subject.kDays == 3)

        // Change to 2025
        try subject.updateYear(2025)
        #expect(subject.kDays == 5)
    }
}
