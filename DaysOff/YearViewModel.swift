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

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }

    func fetchData() {
        do {
            let descriptor = FetchDescriptor<DayOffModel>()
            daysOff = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed")
        }
    }

    func takeDay(_ date: Date, type: DayOffType) {
        let newItem = DayOffModel(date: date, type: type)
        modelContext.insert(newItem)
        try! modelContext.save()
        fetchData()
    }

    func delete(_ dayOffModel: DayOffModel) {
        modelContext.delete(dayOffModel)
        try! modelContext.save()
        fetchData()
    }
}
