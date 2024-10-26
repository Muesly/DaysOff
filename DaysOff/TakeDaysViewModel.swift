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
    var startDateType: DayOffType?
    var endDate: Date?
    var endDateType: DayOffType?

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
        Calendar.current.range(of: .day, in: .month, for: currentDate)!.count
    }

    var numLeadingEmptyItems: Int {
        let calendar = Calendar.current
        let currentMonthComponents = calendar.dateComponents([.month, .year], from: currentDate)
        let dateForFirstDay = calendar.date(from: currentMonthComponents)!
        let dayOfFirstDayOfMonth = calendar.dateComponents([.weekday], from: dateForFirstDay).weekday!
        return dayOfFirstDayOfMonth == 1 ? 6 : dayOfFirstDayOfMonth - 2
    }

    private func clear(start: Bool = false, end: Bool = false) {
        if start {
            startDate = nil
            startDateType = .none
        }
        if end {
            endDate = nil
            endDateType = .none
        }
    }

    func selectDay(day: Int) {
        let calendar = Calendar.current
        var currentMonthComponents = calendar.dateComponents([.month, .year], from: currentDate)
        currentMonthComponents.day = day
        let selectedDate = calendar.date(from: currentMonthComponents)!
        if startDate == nil {
            startDateType = .fullDay
            startDate = selectedDate
        } else {
            if selectedDate == startDate {
                if startDateType == .halfDay {
                    clear(start: true)
                } else {
                    startDateType = .halfDay
                }
            } else {
                if endDate == nil {
                    if selectedDate < startDate! {
                        clear(start: true)
                    } else {
                        endDate = selectedDate
                        endDateType = .fullDay
                    }
                } else {
                    if selectedDate == endDate {
                        if endDateType == .halfDay {
                            clear(start: true, end: true)
                        } else {
                            endDateType = .halfDay
                        }
                    } else {
                        clear(start: true, end: true)
                    }
                }
            }
        }
    }

    func dayOffTypeWithEnd(forDay day: Int) -> DayOffTypeWithEnd? {
        guard let startDate, let startDateType else {
            return nil
        }
        let calendar = Calendar.current
        var currentMonthComponents = calendar.dateComponents([.month, .year], from: currentDate)
        currentMonthComponents.day = day
        let date = calendar.date(from: currentMonthComponents)!

        if date == startDate {
            return DayOffTypeWithEnd(dayOffType: startDateType, isLastDayOff: false)
        } else if let endDate, let endDateType, date >= startDate && date <= endDate {
            return DayOffTypeWithEnd(dayOffType: (date == endDate) ? endDateType : .fullDay, isLastDayOff: true)
        } else {
            return nil
        }
    }

    var dateRange: DateRange? {
        guard let startDate, let startDateType else {
            return nil
        }
        return DateRange(startDate: startDate, startDayOffType: startDateType, endDate: endDate, endDayOffType: endDateType)
    }

    func moveToPreviousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }

    func moveToNextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
}

struct DayOffTypeWithEnd {
    let dayOffType: DayOffType
    let isLastDayOff: Bool
}
