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

    private var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: currentDate)
        guard let startOfYear = Calendar.current.date(from: components) else {
            fatalError("Expects to derives start of year")
        }
        return startOfYear
    }

    private var startOfNextYear: Date {
        guard let startOfNextYear = Calendar.current.date(byAdding: .year, value: 1, to: startOfYear) else {
            fatalError("Expects to derives start of year")
        }
        return startOfNextYear
    }

    private var daysTaken: Float {
        daysOff.reduce(0.0, { $0 + (($1.date >= startOfYear) && ($1.date <= currentDate) ? $1.type.dayLength : 0) })
    }

    private var daysReserved: Float {
        daysOff.reduce(0.0, { $0 + (($1.date > currentDate) && ($1.date < startOfNextYear) ? $1.type.dayLength : 0) })
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
            VStack(alignment: .leading) {
                HStack(spacing: 20) {
                    Spacer()
                    Button {

                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Text("2024")
                        .font(.title2)
                    Button {

                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    Spacer()
                }
                .padding(.top, 20)
                VStack(alignment: .leading) {
                    Text("Starting Total: \(numDaysToTake, format: Self.oneDPFormat) \(dayStr(for: numDaysToTake))")
                    VStack(alignment: .leading) {
                        Text("Days Taken So Far: \(daysTaken, format: Self.oneDPFormat) \(dayStr(for: daysTaken))")
                        Text("Days Left: \(daysLeft, format: Self.oneDPFormat) \(dayStr(for: daysLeft))")
                            .bold()
                        VStack(alignment: .leading) {
                            Text("Days Reserved: \(daysReserved, format: Self.oneDPFormat) \(dayStr(for: daysReserved))")
                            Text("Days To Plan: \(daysToPlan, format: Self.oneDPFormat) \(dayStr(for: daysLeft))")
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
            .navigationTitle("Days Off")
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
    @Environment(\.modelContext) private var modelContext

    let heading: String
    let colour: Color
    @Binding var daysOff: [DayOffModel]

    var body: some View {
        Section {
            ForEach(daysOff) {
                Text("\(DaysOffView.dateFormatter.string(from: $0.date)) - \($0.type.dayLength, format: DaysOffView.oneDPFormat) day")
                    .foregroundStyle(colour)
            }
            .onDelete(perform: deleteDayOff)
        } header: {
            Text(heading)
        }
    }

    private func deleteDayOff(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(daysOff[index])
            }
        }
    }
}

#Preview {
    DaysOffView(currentDate: Date())
        .modelContainer(for: DayOffModel.self, inMemory: true)
}
