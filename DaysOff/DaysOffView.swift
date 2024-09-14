//
//  DaysOffView.swift
//  DaysOff
//
//  Created by Tony Short on 14/09/2024.
//

import SwiftUI
import SwiftData

struct DaysOffView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentDate: Date
    @State private var dateToTake: Date
    @State private var numDaysToTake: Float = 26

    @Query private var daysOff: [DayOffModel]
    @Query private var futureDays: [DayOffModel]
    @Query private var thisMonthDays: [DayOffModel]
    @Query private var lastMonthDays: [DayOffModel]
    @Query private var previousDays: [DayOffModel]

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM YYYY"
        return dateFormatter
    }

    private var daysLeft: Float {
        daysOff.reduce(numDaysToTake, { $0 - $1.type.dayLength })
    }

    init(currentDate: Date) {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
        guard let startOfDay = Calendar.current.date(from: components) else {
            fatalError("Expects to derives start of day")
        }
        self.currentDate = startOfDay
        self.dateToTake = startOfDay

        components.day = 1
        guard let startOfCurrentMonth = Calendar.current.date(from: components),
           let startOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfCurrentMonth),
           let startOfPrevMonth = Calendar.current.date(byAdding: .month, value: -1, to: startOfCurrentMonth) else {
            fatalError("Expects to derives dates")
        }

        let futureDays = #Predicate<DayOffModel> { $0.date >= startOfNextMonth }
        let thisMonthDays = #Predicate<DayOffModel> { $0.date >= startOfCurrentMonth && $0.date < startOfNextMonth }
        let lastMonthDays = #Predicate<DayOffModel> { $0.date >= startOfPrevMonth && $0.date < startOfCurrentMonth }
        let previousDays = #Predicate<DayOffModel> { $0.date < startOfPrevMonth }

        _daysOff = Query()
        _futureDays = Query(filter: futureDays, sort: \DayOffModel.date)
        _thisMonthDays = Query(filter: thisMonthDays, sort: \DayOffModel.date)
        _lastMonthDays = Query(filter: lastMonthDays, sort: \DayOffModel.date)
        _previousDays = Query(filter: previousDays, sort: \DayOffModel.date)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Days Left: \(daysLeft, format: Self.oneDPFormat) days")
                DatePicker(
                        "Day To Take",
                        selection: $dateToTake,
                        displayedComponents: [.date]
                    )
                Button("Take 1 Day") {
                    takeDay(dateToTake, type: .fullDay)
                }
                Button("Take 1/2 Day") {
                    takeDay(dateToTake, type: .halfDay)
                }

                List {
                    DaysOffSection(heading: "Future Months", daysOff: Binding(get: futureDays.reversed, set: { _ in }))
                    DaysOffSection(heading: "This Month", daysOff: Binding(get: thisMonthDays.reversed, set: { _ in }))
                    DaysOffSection(heading: "Last Month", daysOff: Binding(get: lastMonthDays.reversed, set: { _ in }))
                    DaysOffSection(heading: "Previous Months", daysOff: Binding(get: previousDays.reversed, set: { _ in }))
                }
            }
            .navigationTitle("Days Off in 2024")
        }
    }

    static var oneDPFormat: FloatingPointFormatStyle<Float> {
        .number.precision(.fractionLength(0...1))
    }

    private func takeDay(_ date: Date, type: DayOffType) {
        withAnimation {
            let newItem = DayOffModel(date: date, type: type)
            modelContext.insert(newItem)
        }
    }
}

struct DaysOffSection: View {
    let heading: String
    @Binding var daysOff: [DayOffModel]

    var body: some View {
        Section {
            ForEach(daysOff) {
                Text("\(DaysOffView.dateFormatter.string(from: $0.date)) - \($0.type.dayLength, format: DaysOffView.oneDPFormat) day")
            }
        } header: {
            Text(heading)
        }
    }
}

#Preview {
    DaysOffView(currentDate: Date())
        .modelContainer(for: DayOffModel.self, inMemory: true)
}
