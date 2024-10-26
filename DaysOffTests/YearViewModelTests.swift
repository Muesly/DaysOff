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

    @Test func daysStats() throws {
        let currentDate = Calendar.current.date(from: .init(year: 2023, month: 3, day: 1))!
        let subject = YearViewModel(modelContext: .inMemory, currentDate: currentDate)
        try subject.updateEntitledDaysForCurrentYear(26)
        #expect(subject.entitledDays == 26)
        try subject.updateEntitledDaysForCurrentYear(28)
        #expect(subject.entitledDays == 28)
        #expect(subject.kDays == 5)
        #expect(subject.daysLeft == 33)
        #expect(subject.daysTaken == 0)
        #expect(subject.daysReserved == 0)
        try subject.takeRangeOfDays(dateRange: DateRange(startDate: currentDate, startDayOffType: .fullDay, endDate: nil, endDayOffType: nil))
        try subject.takeRangeOfDays(dateRange: DateRange(startDate: currentDate.addingTimeInterval(86400), startDayOffType: .fullDay, endDate: nil, endDayOffType: nil))
        #expect(subject.daysLeft == 32)
        #expect(subject.daysTaken == 1)
        #expect(subject.daysReserved == 1)
    }

    @Test func showKDays() throws {
        let currentDate = Calendar.current.date(from: .init(year: 2023, month: 3, day: 1))!
        let subject = YearViewModel(modelContext: .inMemory, currentDate: currentDate)
        #expect(subject.showKDays == true)
        try subject.updateYear(2024)
        #expect(subject.showKDays == false)
    }

    @Test func defaultKDaysWhenNoDaysTaken() {
        let currentDate = Calendar.current.date(from: .init(year: 2023, month: 3, day: 1))!
        let subject = YearViewModel(modelContext: .inMemory, currentDate: currentDate)
        #expect(subject.kDaysForCurrentYear() == 5)
    }

    @Test func defaultKDaysWhenPreviousYearToAnyHistory() throws {
        let currentDate = Calendar.current.date(from: .init(year: 2023, month: 3, day: 1))!
        let subject = YearViewModel(modelContext: .inMemory, currentDate: currentDate)
        try subject.updateYear(2022)
        #expect(subject.kDaysForCurrentYear() == 5)
    }

    @Test func savingRangesOfDays() throws {
        let currentDate = Calendar.current.date(from: .init(year: 2023, month: 3, day: 1))!
        let startDate = currentDate
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        let subject = YearViewModel(modelContext: .inMemory, currentDate: currentDate)
        try subject.takeRangeOfDays(dateRange: DateRange(startDate: startDate, startDayOffType: .fullDay, endDate: endDate, endDayOffType: .fullDay))
        #expect(subject.daysOff.map { $0.date }.sorted() == [startDate, endDate])
        #expect(subject.daysOff.map { $0.type } == [.fullDay, .fullDay])
    }

    @Test func deletingDay() throws {
        let currentDate = Calendar.current.date(from: .init(year: 2023, month: 3, day: 1))!
        let subject = YearViewModel(modelContext: .inMemory, currentDate: currentDate)
        let dayOff = DayOffModel(date: currentDate, type: .fullDay)
        subject.daysOff = [dayOff]
        try subject.deleteDay(dayOff)
        #expect(subject.daysOff == [])
    }
}
