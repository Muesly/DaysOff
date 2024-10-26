//
//  TakeDaysViewModelTests.swift
//  DaysOffTests
//
//  Created by Tony Short on 20/10/2024.
//

import Foundation
import Testing

@testable import DaysOff

struct TakeDaysViewModelTests {
    @Test func currentMonthStr() {
        let currentDate = Calendar.current.date(from: .init(year: 2024, month: 3, day: 1))!
        let subject = TakeDaysViewModel(currentDate: currentDate)
        #expect(subject.currentMonthStr == "Mar 24")
    }

    @Test func daysInFocusedMonth() {
        let currentDate = Calendar.current.date(from: .init(year: 2024, month: 3))!
        let subject = TakeDaysViewModel(currentDate: currentDate)
        #expect(subject.daysInFocusedMonth == 31)

        subject.currentDate = Calendar.current.date(from: .init(year: 2024, month: 4))!
        #expect(subject.daysInFocusedMonth == 30)
    }

    @Test func numLeadingEmptyItemsInCurrentMonth() {
        let currentDate = Calendar.current.date(from: .init(year: 2024, month: 3))!
        let subject = TakeDaysViewModel(currentDate: currentDate)
        #expect(subject.numLeadingEmptyItems == 4)  // March 2024 started on a Friday

        subject.currentDate = Calendar.current.date(from: .init(year: 2024, month: 4))!
        #expect(subject.numLeadingEmptyItems == 0)  // April 2024 started on a Monday

        subject.currentDate = Calendar.current.date(from: .init(year: 2024, month: 9))!
        #expect(subject.numLeadingEmptyItems == 6)  // Sep 2024 started on a Sunday
    }

    @Test func selectingDaysRepeatably() {
        let currentDate = Calendar.current.date(from: .init(year: 2024, month: 3))!
        let subject = TakeDaysViewModel(currentDate: currentDate)
        subject.selectDay(day: 1)
        #expect(subject.startDate == currentDate)
        #expect(subject.startDateType == .fullDay)

        subject.selectDay(day: 1)
        #expect(subject.startDate == currentDate)
        #expect(subject.startDateType == .halfDay)

        subject.selectDay(day: 1)
        #expect(subject.startDate == nil)
        #expect(subject.startDateType == nil)
    }

    @Test func selectingDateRange() {
        let currentDate = Calendar.current.date(from: .init(year: 2024, month: 3))!
        let subject = TakeDaysViewModel(currentDate: currentDate)

        // Select start
        subject.selectDay(day: 1)
        #expect(subject.startDate == currentDate)
        #expect(subject.startDateType == .fullDay)

        // Select start again for half day
        subject.selectDay(day: 1)
        #expect(subject.startDate == currentDate)
        #expect(subject.startDateType == .halfDay)

        // Deselect start
        subject.selectDay(day: 1)
        #expect(subject.startDate == nil)
        #expect(subject.startDateType == nil)

        // Select start
        subject.selectDay(day: 1)
        #expect(subject.startDate == currentDate)
        #expect(subject.startDateType == .fullDay)

        // Select end
        subject.selectDay(day: 2)
        #expect(subject.startDate == currentDate)
        #expect(subject.startDateType == .fullDay)
        #expect(subject.endDate == Calendar.current.date(byAdding: .day, value: 1, to: currentDate))
        #expect(subject.endDateType == .fullDay)
        #expect(subject.dayOffTypeWithEnd(forDay: 1)?.dayOffType == .fullDay)
        #expect(subject.dayOffTypeWithEnd(forDay: 1)?.isLastDayOff == false)
        #expect(subject.dayOffTypeWithEnd(forDay: 2)?.dayOffType == .fullDay)
        #expect(subject.dayOffTypeWithEnd(forDay: 2)?.isLastDayOff == true)

        // Toggle start to half day
        subject.selectDay(day: 1)
        #expect(subject.startDate == currentDate)
        #expect(subject.startDateType == .halfDay)
        #expect(subject.endDate == Calendar.current.date(byAdding: .day, value: 1, to: currentDate))
        #expect(subject.endDateType == .fullDay)

        // Toggle end to half day
        subject.selectDay(day: 2)
        #expect(subject.startDate == currentDate)
        #expect(subject.startDateType == .halfDay)
        #expect(subject.endDate == Calendar.current.date(byAdding: .day, value: 1, to: currentDate))
        #expect(subject.endDateType == .halfDay)

        // Cancel with end
        subject.selectDay(day: 3)
        #expect(subject.startDate == nil)
        #expect(subject.startDateType == nil)
        #expect(subject.endDate == nil)
        #expect(subject.endDateType == nil)

        // Cancel at start
        subject.selectDay(day: 2)
        subject.selectDay(day: 1)
        #expect(subject.startDate == nil)
        #expect(subject.startDateType == nil)
        #expect(subject.endDate == nil)
        #expect(subject.endDateType == nil)

        // Cancel at end after half day selection
        subject.selectDay(day: 1)
        subject.selectDay(day: 2)
        subject.selectDay(day: 2)
        subject.selectDay(day: 2)
        #expect(subject.startDate == nil)
        #expect(subject.startDateType == nil)
        #expect(subject.endDate == nil)
        #expect(subject.endDateType == nil)
    }
}
