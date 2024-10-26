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
    @State private var isFutureExpanded: Bool = true
    @Binding private var year: Int
    @Query private var futureDays: [DayOffModel]
    @Query private var thisMonthDays: [DayOffModel]
    @Query private var lastMonthDays: [DayOffModel]
    @Query private var previousDays: [DayOffModel]
    @State private var isPickingDate: Bool = false
    @State private var selectedDateRange: DateRange?

    init(year: Binding<Int>, viewModel: YearViewModel) {
        _year = year
        self.viewModel = viewModel
        dateToTake = viewModel.currentDate
        viewModel.year = year.wrappedValue

        _futureDays = Query(filter: viewModel.futureDaysPredicate, sort: \DayOffModel.date)
        _thisMonthDays = Query(filter: viewModel.thisMonthDaysPredicate, sort: \DayOffModel.date)
        _lastMonthDays = Query(filter: viewModel.lastMonthDaysPredicate, sort: \DayOffModel.date)
        _previousDays = Query(filter: viewModel.previousDaysPredicate, sort: \DayOffModel.date)
    }

    var body: some View {
        DaysStatsView(viewModel: viewModel, year: viewModel.year)
        ZStack(alignment: .top) {
            VStack(alignment: .center) {
                Button {
                    withAnimation {
                        isPickingDate = true
                    }
                } label: {
                    HStack {
                        Text("Take Day")
                        Image(systemName: "calendar")
                    }
                }
                .buttonStyle(.borderedProminent)
                ScrollViewReader { proxy in
                    List {
                        DaysOffSection(heading: "Future Months", colour: .foregroundSecondary, daysOff: Binding(get: futureDays.reversed, set: { _ in }), onDelete: onDelete)   // .reversed so that an array
                        DaysOffSection(heading: "This Month", colour: .foregroundPrimary, daysOff: Binding(get: thisMonthDays.reversed, set: { _ in }), onDelete: onDelete)
                        DaysOffSection(heading: "Last Month", colour: .foregroundPrimary, daysOff: Binding(get: lastMonthDays.reversed, set: { _ in }), onDelete: onDelete)
                        DaysOffSection(heading: "Previous Months", colour: .foregroundSecondary, daysOff: Binding(get: previousDays.reversed, set: { _ in }), onDelete: onDelete)
                    }
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        try? viewModel.fetchData()
                        proxy.scrollTo("This Month", anchor: .top)
                    }
                }
            }
            if isPickingDate {
                TakeDaysView(isPresented: $isPickingDate,
                             selectedRange: $selectedDateRange,
                             viewModel: TakeDaysViewModel(currentDate: viewModel.currentDate))
                .offset(x: 0, y: 45)
            }
        }
        .onChange(of: year) {
            do {
                try viewModel.updateYear(year)
            } catch {
                print("Failed to change year")
            }
        }
        .onChange(of: selectedDateRange) {
            if let selectedDateRange {
                withAnimation {
                    do {
                        try viewModel.takeRangeOfDays(dateRange: selectedDateRange)
                    } catch {
                        print("Failed to take range of days")
                    }
                }
            }
            selectedDateRange = nil
        }
    }

    private func onDelete(_ dayOffModel: DayOffModel) {
        do {
            try viewModel.deleteDay(dayOffModel)
        } catch {
            print("Failed to delete day: \(error)")
        }
    }
}

#Preview {
    YearView(year: .constant(2024), viewModel: YearViewModel(modelContext: .inMemory, currentDate: Date()))
}

struct DateRange: Equatable {
    let startDate: Date
    let startDayOffType: DayOffType
    let endDate: Date?
    let endDayOffType: DayOffType?
}
