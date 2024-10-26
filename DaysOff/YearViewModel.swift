//
//  YearViewModel.swift
//  DaysOff
//
//  Created by Tony Short on 21/09/2024.
//

import Foundation
import SwiftData

@Observable
final class YearViewModel {
    static let defaultKDays: Float = 5
    static let defaultEntitledDays: Float = 26

    var modelContext: ModelContext
    var daysOff = [DayOffModel]()
    var entitledDays: Float
    var kDays: Float
    var yearValue: Int
    let currentDate: Date

    var futureDaysPredicate: Predicate<DayOffModel>?
    var thisMonthDaysPredicate: Predicate<DayOffModel>?
    var lastMonthDaysPredicate: Predicate<DayOffModel>?
    var previousDaysPredicate: Predicate<DayOffModel>?

    var year: Int {
        get { yearValue }
        set { yearValue = newValue
              setPredicates() }
    }

    init(modelContext: ModelContext,
         currentDate: Date) {
        self.modelContext = modelContext
        self.currentDate = currentDate
        self.yearValue = Calendar.current.dateComponents([.year], from: currentDate).year!
        self.kDays = 0
        self.entitledDays = 0.0
    }

    private func yearOfFirstDayOff() -> Int? {
        var refDate: Date
        if let firstDay = daysOff.first {
            refDate = firstDay.date
        } else {
            refDate = currentDate
        }
        return NSCalendar.current.dateComponents([.year], from: refDate).year
    }

    var showKDays: Bool {
        yearOfFirstDayOff() == year
    }

    private func startingDays(forYear year: Int) -> YearStartingDaysModel? {
        let predicate: Predicate<YearStartingDaysModel> = #Predicate { $0.year == year }
        let fetchDescriptor = FetchDescriptor<YearStartingDaysModel>(predicate: predicate)
        return try? modelContext.fetch(fetchDescriptor).first
    }

    func kDaysForCurrentYear() -> Float {
        guard let firstYear = yearOfFirstDayOff(),
              year >= firstYear else {
            return Self.defaultKDays
        }
        var previousKDays: Float = (startingDays(forYear: firstYear)?.kDays) ?? Self.defaultKDays
        var previousYear = firstYear
        while previousYear < year {
            var previousYearEntitledDays: Float = Self.defaultEntitledDays
            if let foundYear = startingDays(forYear: previousYear) {
                previousYearEntitledDays = foundYear.entitledDays
            }
            let prevYearNumDaysToTake = previousKDays + previousYearEntitledDays
            let prevYearDaysTaken = daysTaken(year: previousYear, currentDate: currentDate) + daysReserved(year: previousYear, currentDate: currentDate)
            let prevYearDaysLeft = prevYearNumDaysToTake - prevYearDaysTaken

            previousKDays = max(0, min(Self.defaultKDays, prevYearDaysLeft))
            previousYear += 1
        }
        return previousKDays
    }

    private func setPredicates() {
        guard let startOfFocusedYear = Calendar.current.date(from: DateComponents(year: year)),
              let endOfFocusedYear = Calendar.current.date(byAdding: .year, value: 1, to: startOfFocusedYear) else {
            fatalError("Expects to derives start of year")
        }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
        components.day = 1
        guard let startOfCurrentMonth = Calendar.current.date(from: components),
           let startOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfCurrentMonth),
           let startOfPrevMonth = Calendar.current.date(byAdding: .month, value: -1, to: startOfCurrentMonth) else {
            fatalError("Expects to derives dates")
        }

        futureDaysPredicate = #Predicate<DayOffModel> { $0.date >= startOfNextMonth &&
                                                        $0.date >= startOfFocusedYear &&
                                                        $0.date < endOfFocusedYear }

        thisMonthDaysPredicate = #Predicate<DayOffModel> { $0.date >= startOfCurrentMonth &&
                                                      $0.date < startOfNextMonth &&
                                                      $0.date >= startOfFocusedYear &&
                                                      $0.date < endOfFocusedYear }

        lastMonthDaysPredicate = #Predicate<DayOffModel> { $0.date >= startOfPrevMonth &&
                                                      $0.date < startOfCurrentMonth &&
                                                      $0.date >= startOfFocusedYear &&
                                                      $0.date < endOfFocusedYear }

        previousDaysPredicate = #Predicate<DayOffModel> { $0.date < startOfPrevMonth &&
                                                     $0.date >= startOfFocusedYear &&
                                                     $0.date < endOfFocusedYear }
    }

    func fetchData() throws {
        let descriptor = FetchDescriptor<DayOffModel>()
        daysOff = try modelContext.fetch(descriptor)
        try updateYear(self.year)
    }

    func takeRangeOfDays(dateRange: DateRange) throws {
        var dateBeingTaken = dateRange.startDate
        var typeBeingTaken = dateRange.startDayOffType
        let endDate = dateRange.endDate ?? dateRange.startDate
        let endDayOffType = dateRange.endDayOffType ?? dateRange.startDayOffType

        while dateBeingTaken <= endDate {
            let newItem = DayOffModel(date: dateBeingTaken, type: typeBeingTaken)
            modelContext.insert(newItem)
            dateBeingTaken.addTimeInterval(86400)
            typeBeingTaken = (dateBeingTaken == endDate) ? endDayOffType : .fullDay // In between start and end, full days assumed
        }
        try modelContext.save()
        try fetchData()
    }

    func takeDay(_ date: Date, type: DayOffType) throws {
        let newItem = DayOffModel(date: date, type: type)
        modelContext.insert(newItem)
        try modelContext.save()
        try fetchData()
    }

    func delete(_ dayOffModel: DayOffModel) throws {
        modelContext.delete(dayOffModel)
        try modelContext.save()
        try fetchData()
    }

    var daysTaken: Float {
        daysTaken(year: year, currentDate: currentDate)
    }

    var daysReserved: Float {
        daysReserved(year: year, currentDate: currentDate)
    }

    var numDaysToTake: Float {
        entitledDays + kDays
    }

    var daysLeft: Float {
        numDaysToTake - daysTaken
    }

    var daysToPlan: Float {
        daysLeft - daysReserved
    }

    func daysTaken(year: Int, currentDate: Date) -> Float {
        guard let startOfYear = Calendar.current.date(from: DateComponents(year: year)),
              let endOfYear = Calendar.current.date(byAdding: .year, value: 1, to: startOfYear) else {
            fatalError("Expects to derives start of year")
        }
        let currentYearComponents = Calendar.current.dateComponents([.year], from: currentDate)
        let maxDate = (currentYearComponents.year == year) ? currentDate : endOfYear
        return daysOff.reduce(0.0, { $0 + (($1.date >= startOfYear) && ($1.date <= maxDate) ? $1.type.dayLength : 0) })
    }

    func daysReserved(year: Int, currentDate: Date) -> Float {
        let components = Calendar.current.dateComponents([.year], from: currentDate)
        guard let startOfCurrentYear = Calendar.current.date(from: components),
              let endOfCurrentYear = Calendar.current.date(byAdding: .year, value: 1, to: startOfCurrentYear) else {
            fatalError("Expects to derives start of year")
        }
        let currentYearComponents = Calendar.current.dateComponents([.year], from: currentDate)

        return daysOff.reduce(0.0, {
            return $0 + ((year == currentYearComponents.year) && ($1.date > currentDate) && ($1.date < endOfCurrentYear) ? $1.type.dayLength : 0)
        })
    }

    func deleteDay(_ dayOffModel: DayOffModel) throws {
        try delete(dayOffModel)
        try modelContext.save()
    }

    func updateYear(_ year: Int) throws {
        self.year = year
        self.entitledDays = try entitledDaysForCurrentYear()
        self.kDays = kDaysForCurrentYear()
    }

    private func entitledDaysForCurrentYear() throws -> Float {
        if let foundYear = startingDays(forYear: year) {
            return foundYear.entitledDays
        } else {
            let entitledDays = Self.defaultEntitledDays
            let newEntry = YearStartingDaysModel(year: year,
                                                 entitledDays: entitledDays,
                                                 kDays: Self.defaultKDays)
            modelContext.insert(newEntry)
            try modelContext.save()
            return entitledDays
        }
    }

    func updateEntitledDaysForCurrentYear(_ entitledDays: Float) throws {
        if let yearEntry = startingDays(forYear: year) {
            yearEntry.entitledDays = entitledDays
            modelContext.insert(yearEntry)
        } else {
            let yearEntry = YearStartingDaysModel(year: year,
                                              entitledDays: entitledDays,
                                              kDays: Self.defaultKDays)
            modelContext.insert(yearEntry)
        }
        try modelContext.save()
        self.entitledDays = entitledDays
        self.kDays = kDaysForCurrentYear()
    }

    func updateStartingKDays(_ kDays: Float) throws {
        guard let firstYear = yearOfFirstDayOff(),
              let yearEntry = startingDays(forYear: firstYear) else {
            return
        }
        yearEntry.kDays = kDays
        modelContext.insert(yearEntry)
        try modelContext.save()

        self.kDays = kDaysForCurrentYear()
    }
}
