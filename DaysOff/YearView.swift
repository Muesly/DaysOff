//
//  YearView.swift
//  DaysOff
//
//  Created by Tony Short on 18/09/2024.
//

import SwiftData
import SwiftUI

struct YearView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dateToTake: Date
    @State private var entitledDays: Float = 26
    @State private var kDays: Float = 5
    @State private var viewModel: YearViewModel
    @Binding private var year: Int
    @Binding private var currentDate: Date

    @Query private var daysOff: [DayOffModel]
    @Query private var futureDays: [DayOffModel]
    @Query private var thisMonthDays: [DayOffModel]
    @Query private var lastMonthDays: [DayOffModel]
    @Query private var previousDays: [DayOffModel]

    private var daysTaken: Float {
        guard let startOfYear = Calendar.current.date(from: DateComponents(year: year)),
              let endOfYear = Calendar.current.date(byAdding: .year, value: 1, to: startOfYear) else {
            fatalError("Expects to derives start of year")
        }
        let currentYearComponents = Calendar.current.dateComponents([.year], from: currentDate)
        let maxDate = (currentYearComponents.year == year) ? currentDate : endOfYear
        return daysOff.reduce(0.0, { $0 + ((year <= currentYearComponents.year!) && ($1.date >= startOfYear) && ($1.date <= maxDate) ? $1.type.dayLength : 0) })
    }

    private var daysReserved: Float {
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

    private var numDaysToTake: Float {
        entitledDays + kDays
    }

    private var daysLeft: Float {
        numDaysToTake - daysTaken
    }

    private func dayStr(for number: Float) -> String {
        (number == 1) ? "day" : "days"
    }

    private var daysToPlan: Float {
        daysLeft - daysReserved
    }

    init(currentDate: Binding<Date>, year: Binding<Int>, viewModel: YearViewModel) {
        _year = year
        _currentDate = currentDate
        self.dateToTake = currentDate.wrappedValue
        self.viewModel = viewModel

        guard let startOfFocusedYear = Calendar.current.date(from: DateComponents(year: year.wrappedValue)),
              let endOfFocusedYear = Calendar.current.date(byAdding: .year, value: 1, to: startOfFocusedYear) else {
            fatalError("Expects to derives start of year")
        }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate.wrappedValue)
        components.day = 1
        guard let startOfCurrentMonth = Calendar.current.date(from: components),
           let startOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfCurrentMonth),
           let startOfPrevMonth = Calendar.current.date(byAdding: .month, value: -1, to: startOfCurrentMonth) else {
            fatalError("Expects to derives dates")
        }
        let futureDays = #Predicate<DayOffModel> { $0.date >= startOfNextMonth &&
                                                   $0.date >= startOfFocusedYear &&
                                                   $0.date < endOfFocusedYear }

        let thisMonthDays = #Predicate<DayOffModel> { $0.date >= startOfCurrentMonth &&
                                                      $0.date < startOfNextMonth &&
                                                      $0.date >= startOfFocusedYear &&
                                                      $0.date < endOfFocusedYear }

        let lastMonthDays = #Predicate<DayOffModel> { $0.date >= startOfPrevMonth &&
                                                      $0.date < startOfCurrentMonth &&
                                                      $0.date >= startOfFocusedYear &&
                                                      $0.date < endOfFocusedYear }

        let previousDays = #Predicate<DayOffModel> { $0.date < startOfPrevMonth &&
                                                     $0.date >= startOfFocusedYear &&
                                                     $0.date < endOfFocusedYear }

        _daysOff = Query()
        _futureDays = Query(filter: futureDays, sort: \DayOffModel.date)
        _thisMonthDays = Query(filter: thisMonthDays, sort: \DayOffModel.date)
        _lastMonthDays = Query(filter: lastMonthDays, sort: \DayOffModel.date)
        _previousDays = Query(filter: previousDays, sort: \DayOffModel.date)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Starting Total: \(numDaysToTake, format: YearViewModel.oneDPFormat) \(dayStr(for: numDaysToTake)) (\(entitledDays, format: YearViewModel.oneDPFormat) + \(kDays, format: YearViewModel.oneDPFormat))")
                NavigationLink {
                    EditStartingNumDaysView(entitledDays:  $entitledDays, kDays: $kDays)
                } label: {
                    Image(systemName: "pencil")
                }
            }
            VStack(alignment: .leading) {
                Text("Days Taken So Far: \(daysTaken, format: YearViewModel.oneDPFormat) \(dayStr(for: daysTaken))")
                Text("Days Left: \(daysLeft, format: YearViewModel.oneDPFormat) \(dayStr(for: daysLeft))")
                    .bold()
                VStack(alignment: .leading) {
                    Text("Days Reserved: \(daysReserved, format: YearViewModel.oneDPFormat) \(dayStr(for: daysReserved))")
                    Text("Days To Plan: \(daysToPlan, format: YearViewModel.oneDPFormat) \(dayStr(for: daysLeft))")
                }.padding(.leading, 20)
            }.padding(.leading, 20)
        }
        .padding()
        HStack {
            DatePicker(
                "",
                selection: $dateToTake,
                displayedComponents: [.date]
            )
            Button("Take 1 Day") {
                takeDay(dateToTake, type: .fullDay)
            }
            Button("Take 1/2 Day") {
                takeDay(dateToTake, type: .halfDay)
            }
        }
        .padding()
        List {
            DaysOffSection(heading: "Future Months", colour: .gray, daysOff: Binding(get: futureDays.reversed, set: { _ in }))
            DaysOffSection(heading: "This Month", colour: .black, daysOff: Binding(get: thisMonthDays.reversed, set: { _ in }))
            DaysOffSection(heading: "Last Month", colour: .black, daysOff: Binding(get: lastMonthDays.reversed, set: { _ in }))
            DaysOffSection(heading: "Previous Months", colour: .gray, daysOff: Binding(get: previousDays.reversed, set: { _ in }))
        }
    }

    private func takeDay(_ date: Date, type: DayOffType) {
        withAnimation {
            let newItem = DayOffModel(date: date, type: type)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    YearView(currentDate: .constant(Date()), year: .constant(2024), viewModel: YearViewModel())
}
