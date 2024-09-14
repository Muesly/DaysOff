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
    @Query(sort: \DayOffModel.date, order: .reverse) private var daysOff: [DayOffModel]
    @State private var dateToTake: Date
    @State private var numDaysToTake: Float = 26
    @State private var dateFormatter: DateFormatter

    private var daysLeft: Float {
        daysOff.reduce(numDaysToTake, { $0 - $1.type.dayLength })
    }

    init(dateToTake: Date) {
        self.dateToTake = dateToTake
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM YYYY"
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Days Left: \(daysLeft, format: oneDPFormat) days")
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
                    Section {
                        ForEach(daysOff) {
                            Text("\(dateFormatter.string(from: $0.date)) - \($0.type.dayLength, format: oneDPFormat) day")
                        }
                    } header: {
                        Text("Days Taken")
                    }
                }
            }
            .navigationTitle("Days Off in 2024")
        }
    }

    private var oneDPFormat: FloatingPointFormatStyle<Float> {
        .number.precision(.fractionLength(0...1))
    }

    private func takeDay(_ date: Date, type: DayOffType) {
        withAnimation {
            let newItem = DayOffModel(date: date, type: type)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    DaysOffView(dateToTake: Date())
        .modelContainer(for: DayOffModel.self, inMemory: true)
}
