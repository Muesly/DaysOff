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
    @State private var isEditStartingNumDaysPresented = false
    @Query private var futureDays: [DayOffModel]
    @Query private var thisMonthDays: [DayOffModel]
    @Query private var lastMonthDays: [DayOffModel]
    @Query private var previousDays: [DayOffModel]

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
        daysLeft - viewModel.daysReserved(year: year, currentDate: currentDate)
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

        _futureDays = Query(filter: futureDays, sort: \DayOffModel.date)
        _thisMonthDays = Query(filter: thisMonthDays, sort: \DayOffModel.date)
        _lastMonthDays = Query(filter: lastMonthDays, sort: \DayOffModel.date)
        _previousDays = Query(filter: previousDays, sort: \DayOffModel.date)
    }
    
    var body: some View {
        let daysReserved = viewModel.daysReserved(year: year, currentDate: currentDate)
        VStack(alignment: .leading) {
            HStack {
                Text("Starting Total: \(numDaysToTake, format: Formatters.oneDPFormat) \(dayStr(for: numDaysToTake)) (\(entitledDays, format: Formatters.oneDPFormat) + \(kDays, format: Formatters.oneDPFormat))")
                Button {
                    isEditStartingNumDaysPresented = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityIdentifier("Edit Starting Number Of Days")
            }
            VStack(alignment: .leading) {
                Text("Days Taken So Far: \(daysTaken, format: Formatters.oneDPFormat) \(dayStr(for: daysTaken))")
                Text("Days Left: \(daysLeft, format: Formatters.oneDPFormat) \(dayStr(for: daysLeft))")
                    .bold()
                VStack(alignment: .leading) {
                    Text("Days Reserved: \(daysReserved, format: Formatters.oneDPFormat) \(dayStr(for: daysReserved))")
                    Text("Days To Plan: \(daysToPlan, format: Formatters.oneDPFormat) \(dayStr(for: daysLeft))")
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
                withAnimation {
                    do {
                        try viewModel.takeDay(dateToTake, type: .fullDay)
                    } catch {
                        print("Failed to take day: \(error)")
                    }
                }
            }
            Button("Take 1/2 Day") {
                withAnimation {
                    do {
                        try viewModel.takeDay(dateToTake, type: .halfDay)
                    } catch {
                        print("Failed to take half day: \(error)")
                    }
                }
            }
        }
        .padding()
        List {
            DaysOffSection(heading: "Future Months", colour: .foregroundSecondary, daysOff: Binding(get: futureDays.reversed, set: { _ in }), onDelete: onDelete)
            DaysOffSection(heading: "This Month", colour: .foregroundPrimary, daysOff: Binding(get: thisMonthDays.reversed, set: { _ in }), onDelete: onDelete)
            DaysOffSection(heading: "Last Month", colour: .foregroundPrimary, daysOff: Binding(get: lastMonthDays.reversed, set: { _ in }), onDelete: onDelete)
            DaysOffSection(heading: "Previous Months", colour: .foregroundSecondary, daysOff: Binding(get: previousDays.reversed, set: { _ in }), onDelete: onDelete)
        }
        .scrollContentBackground(.hidden)
        .onAppear {
            try? viewModel.fetchData()
            updateStartingDays()
        }
        .onChange(of: year) {
            updateStartingDays()
        }
        .onChange(of: entitledDays) {
            saveYearStartingDays()
        }
        .onChange(of: kDays) {
            saveYearStartingDays()
        }
        .sheet(isPresented: $isEditStartingNumDaysPresented) {
            EditStartingNumDaysView(entitledDays: $entitledDays, kDays: $kDays)
        }
    }

    private func onDelete(_ dayOffModel: DayOffModel) {
        do {
            try viewModel.delete(dayOffModel)
            try modelContext.save()
        } catch {
            print("Failed to delete day: \(error)")
        }
    }

    private var daysTaken: Float {
        viewModel.daysTaken(year: year, currentDate: currentDate)
    }

    private func updateStartingDays() {
        let predicate: Predicate<YearStartingDaysModel> = #Predicate { $0.year == year }
        let fetchDescriptor = FetchDescriptor<YearStartingDaysModel>(predicate: predicate)
        if let yearStartingDaysEntries = try? modelContext.fetch(fetchDescriptor),
           let foundYear = yearStartingDaysEntries.first {
            self.entitledDays = foundYear.entitledDays
            self.kDays = foundYear.kDays
        } else {
            self.entitledDays = 26
            self.kDays = 5 - viewModel.daysTaken(year: year - 1, currentDate: currentDate)
            saveYearStartingDays()
        }
    }

    private func saveYearStartingDays() {
        do {
            let newEntry = YearStartingDaysModel(year: self.year, entitledDays: entitledDays, kDays: kDays)
            modelContext.insert(newEntry)
            try modelContext.save()
        } catch {
            print("Failed to save year's starting days")
        }
    }
}

#Preview {
    YearView(currentDate: .constant(Date()), year: .constant(2024), viewModel: YearViewModel(modelContext: .inMemory))
}
