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
    @State private var year: Int

    init(currentDate: Date) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
        guard let startOfDay = Calendar.current.date(from: components) else {
            fatalError("Expects to derives start of day")
        }
        self.currentDate = startOfDay
        self.year = components.year!
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                YearSelectorView(year: $year)
                    .padding(.top, 20)
                YearView(currentDate: $currentDate, year: $year, viewModel: YearViewModel())
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.5, green: 0.8, blue: 1),
                                                           Color(red: 1, green: 1, blue: 0.5)]), startPoint: .top, endPoint: .bottom)
                )
            .navigationTitle("Days Off")
        }
    }
}

#Preview {
    DaysOffView(currentDate: Date())
        .modelContainer(for: DayOffModel.self, inMemory: true)
}
