//
//  DaysStatsView.swift
//  DaysOff
//
//  Created by Tony Short on 05/10/2024.
//

import SwiftUI

struct DaysStatsView: View {
    @State private var isEditStartingNumDaysPresented = false
    @State private var isExpanded = false
    @State private var entitledDays: Float
    @State private var kDays: Float

    let viewModel: YearViewModel
    let year: Int

    init(viewModel: YearViewModel, year: Int) {
        self.viewModel = viewModel
        self.year = year

        entitledDays = viewModel.entitledDays
        kDays = viewModel.kDays
    }

    var body: some View {
        HStack {
            Spacer()
            Button {
                isExpanded = !isExpanded
            } label: {
                VStack(alignment: .center) {
                    if isExpanded {
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
                    } else {
                        Text("Days Left: \(viewModel.daysLeft, format: Formatters.oneDPFormat) \(dayStr(for: viewModel.daysLeft))")
                            .font(.title2)
                            .bold()
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .padding(.top, 1)
                }
                .foregroundColor(.primary)
            }
            .accessibilityIdentifier("Expand Button")
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isEditStartingNumDaysPresented) {
            EditStartingNumDaysView(entitledDays: $entitledDays, kDays: $kDays)
        }
        .onChange(of: entitledDays) {
            viewModel.entitledDays = entitledDays
            try? viewModel.updateStartingDays()
        }
        .onChange(of: kDays) {
            viewModel.kDays = kDays
            try? viewModel.updateStartingDays()
        }
    }

    private func dayStr(for number: Float) -> String {
        (number == 1) ? "day" : "days"
    }
}

#Preview {
    DaysStatsView(viewModel: .init(modelContext: .inMemory, currentDate: Date()), year: 2024)
}
