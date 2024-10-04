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
    @State private var viewModel: YearViewModel
    @Binding private var year: Int
    @State private var isEditStartingNumDaysPresented = false
    @Query private var futureDays: [DayOffModel]
    @Query private var thisMonthDays: [DayOffModel]
    @Query private var lastMonthDays: [DayOffModel]
    @Query private var previousDays: [DayOffModel]

    private func dayStr(for number: Float) -> String {
        (number == 1) ? "day" : "days"
    }

    init(currentDate: Binding<Date>, year: Binding<Int>, viewModel: YearViewModel) {
        _year = year
        self.dateToTake = currentDate.wrappedValue
        self.viewModel = viewModel
        self.viewModel.year = year.wrappedValue
        self.viewModel.currentDate = currentDate.wrappedValue

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
        VStack(alignment: .leading) {
            HStack {
                Text("Starting Total: \(viewModel.numDaysToTake, format: Formatters.oneDPFormat) \(dayStr(for: viewModel.numDaysToTake)) (\(viewModel.entitledDays, format: Formatters.oneDPFormat) + \(viewModel.kDays, format: Formatters.oneDPFormat))")
                Button {
                    isEditStartingNumDaysPresented = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityIdentifier("Edit Starting Number Of Days")
            }
            VStack(alignment: .leading) {
                Text("Days Taken So Far: \(viewModel.daysTaken, format: Formatters.oneDPFormat) \(dayStr(for: viewModel.daysTaken(year: year, currentDate: viewModel.currentDate)))")
                Text("Days Left: \(viewModel.daysLeft, format: Formatters.oneDPFormat) \(dayStr(for: viewModel.daysLeft))")
                    .bold()
                VStack(alignment: .leading) {
                    Text("Days Reserved: \(viewModel.daysReserved, format: Formatters.oneDPFormat) \(dayStr(for: viewModel.daysReserved))")
                    Text("Days To Plan: \(viewModel.daysToPlan, format: Formatters.oneDPFormat) \(dayStr(for: viewModel.daysLeft))")
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
            viewModel.year = year
            updateStartingDays()
        }
        .onChange(of: viewModel.entitledDays) {
            saveYearStartingDays()
        }
        .onChange(of: viewModel.kDays) {
            saveYearStartingDays()
        }
        .sheet(isPresented: $isEditStartingNumDaysPresented) {
            EditStartingNumDaysView(entitledDays: $viewModel.entitledDays, kDays: $viewModel.kDays)
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

    private func updateStartingDays() {
        let predicate: Predicate<YearStartingDaysModel> = #Predicate { $0.year == year }
        let fetchDescriptor = FetchDescriptor<YearStartingDaysModel>(predicate: predicate)
        if let yearStartingDaysEntries = try? modelContext.fetch(fetchDescriptor),
           let foundYear = yearStartingDaysEntries.first {
            self.viewModel.entitledDays = foundYear.entitledDays
            self.viewModel.kDays = foundYear.kDays
        } else {
            self.viewModel.entitledDays = 26
            self.viewModel.kDays = 5 - viewModel.daysTaken(year: year - 1, currentDate: viewModel.currentDate)
            saveYearStartingDays()
        }
    }

    private func saveYearStartingDays() {
        do {
            let newEntry = YearStartingDaysModel(year: self.year, entitledDays: viewModel.entitledDays, kDays: viewModel.kDays)
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
