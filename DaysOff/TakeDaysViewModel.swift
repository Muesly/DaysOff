//
//  TakeDaysViewModel.swift
//  DaysOff
//
//  Created by Tony Short on 15/10/2024.
//

import Foundation

@Observable
class TakeDaysViewModel {
    var currentDate: Date
    let dateFormatter: DateFormatter
    let daysOfWeek: [DayOfWeek]
    var startDate: Date?

    struct DayOfWeek: Identifiable {
        var id: Int {
            weekDay
        }
        let dayStr: String
        let weekDay: Int
    }

    init(currentDate: Date) {
        self.currentDate = currentDate

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yy"
        self.dateFormatter = dateFormatter

        self.daysOfWeek = [.init(dayStr: "M", weekDay: 1),
                           .init(dayStr: "T", weekDay: 2),
                           .init(dayStr: "W", weekDay: 3),
                           .init(dayStr: "T", weekDay: 4),
                           .init(dayStr: "F", weekDay: 5),
                           .init(dayStr: "S", weekDay: 6),
                           .init(dayStr: "S", weekDay: 7)]
    }

    var currentMonthStr: String {
        dateFormatter.string(from: currentDate)
    }

    var daysInFocusedMonth: Int {
        NSCalendar.current.range(of: .day, in: .month, for: currentDate)!.count
    }

    var numLeadingEmptyItems: Int {
        let calendar = NSCalendar.current
        let currentMonthComponents = calendar.dateComponents([.month, .year], from: currentDate)
        let dateForFirstDay = calendar.date(from: currentMonthComponents)!
        let dayOfFirstDayOfMonth = calendar.dateComponents([.weekday], from: dateForFirstDay).weekday!
        return dayOfFirstDayOfMonth == 1 ? 6 : dayOfFirstDayOfMonth - 2
    }

    func selectDay(day: Int) {
        let calendar = NSCalendar.current
        var currentMonthComponents = calendar.dateComponents([.month, .year], from: currentDate)
        currentMonthComponents.day = day
        startDate = calendar.date(from: currentMonthComponents)!
    }

    func isDaySelected(_ day: Int) -> Bool {
        guard let startDate else {
            return false
        }
        let calendar = NSCalendar.current
        var currentMonthComponents = calendar.dateComponents([.month, .year], from: startDate)
        currentMonthComponents.day = day
        let date = calendar.date(from: currentMonthComponents)!
        return date == startDate
    }

    var dateRange: DateRange? {
        guard let startDate else {
            return nil
        }
        return DateRange(startDate: startDate, startDayOffType: .fullDay, endDate: nil, endDayOffType: nil)
    }

    func moveToPreviousMonth() {
        if let newDate = NSCalendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }

    func moveToNextMonth() {
        if let newDate = NSCalendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
}
