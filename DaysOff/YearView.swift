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
    @State private var entitledDays: Float
    @State private var kDays: Float
    @State private var isEditStartingNumDaysPresented = false
    @Query private var futureDays: [DayOffModel]
    @Query private var thisMonthDays: [DayOffModel]
    @Query private var lastMonthDays: [DayOffModel]
    @Query private var previousDays: [DayOffModel]

    init(year: Binding<Int>, viewModel: YearViewModel) {
        _year = year
        self.viewModel = viewModel
        dateToTake = viewModel.currentDate
        entitledDays = viewModel.entitledDays
        kDays = viewModel.kDays
        viewModel.year = year.wrappedValue

        _futureDays = Query(filter: viewModel.futureDaysPredicate, sort: \DayOffModel.date)
        _thisMonthDays = Query(filter: viewModel.thisMonthDaysPredicate, sort: \DayOffModel.date)
        _lastMonthDays = Query(filter: viewModel.lastMonthDaysPredicate, sort: \DayOffModel.date)
        _previousDays = Query(filter: viewModel.previousDaysPredicate, sort: \DayOffModel.date)
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
            DaysOffSection(heading: "Future Months", colour: .foregroundSecondary, daysOff: Binding(get: futureDays.reversed, set: { _ in }), onDelete: onDelete)   // .reversed so that an array
            DaysOffSection(heading: "This Month", colour: .foregroundPrimary, daysOff: Binding(get: thisMonthDays.reversed, set: { _ in }), onDelete: onDelete)
            DaysOffSection(heading: "Last Month", colour: .foregroundPrimary, daysOff: Binding(get: lastMonthDays.reversed, set: { _ in }), onDelete: onDelete)
            DaysOffSection(heading: "Previous Months", colour: .foregroundSecondary, daysOff: Binding(get: previousDays.reversed, set: { _ in }), onDelete: onDelete)
        }
        .scrollContentBackground(.hidden)
        .onAppear {
            try? viewModel.fetchData()
            try? viewModel.getOrUpdateStartingDays()
        }
        .onChange(of: year) {
            viewModel.year = year
            try? viewModel.getOrUpdateStartingDays()
        }
        .onChange(of: entitledDays) {
            viewModel.entitledDays = entitledDays
            try? viewModel.updateStartingDays()
        }
        .onChange(of: kDays) {
            viewModel.kDays = kDays
            try? viewModel.updateStartingDays()
        }
        .sheet(isPresented: $isEditStartingNumDaysPresented) {
            EditStartingNumDaysView(entitledDays: $entitledDays, kDays: $kDays)
        }
    }

    private func dayStr(for number: Float) -> String {
        (number == 1) ? "day" : "days"
    }

    private func onDelete(_ dayOffModel: DayOffModel) {
        do {
            try viewModel.deleteDay(dayOffModel)
        } catch {
            print("Failed to delete day: \(error)")
        }
    }

    private func updateStartingDays() {
        do {
            try viewModel.updateStartingDays()
        } catch {
            print("Failed to update year's atarting days: \(error)")
        }
    }
}

#Preview {
    YearView(year: .constant(2024), viewModel: YearViewModel(modelContext: .inMemory, currentDate: Date()))
}
