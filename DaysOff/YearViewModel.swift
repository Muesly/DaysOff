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
    var modelContext: ModelContext
    var daysOff = [DayOffModel]()
    var entitledDays: Float = 26
    var kDays: Float = 5
    var year: Int = 0
    var currentDate: Date = Date()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchData() throws {
        let descriptor = FetchDescriptor<DayOffModel>()
        daysOff = try modelContext.fetch(descriptor)
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

    var daysReserved: Float {
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
}
