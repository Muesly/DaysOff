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
}
