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
                                DayInfoRow(title: "Starting Total", value: viewModel.numDaysToTake)
                                Text("(\(viewModel.entitledDays, format: Formatters.oneDPFormat) + \(viewModel.kDays, format: Formatters.oneDPFormat))")
                                    .foregroundColor(.secondary)
                                Button {
                                    isEditStartingNumDaysPresented = true
                                } label: {
                                    Image(systemName: "pencil")
                                }
                                .accessibilityIdentifier("Edit Starting Number Of Days")
                            }
                            
                            Group {
                                DayInfoRow(title: "Days Taken So Far", value: viewModel.daysTaken(year: year, currentDate: viewModel.currentDate))
                                DayInfoRow(title: "Days Left", value: viewModel.daysLeft)
                                    .fontWeight(.bold)

                                Group {
                                    DayInfoRow(title: "Days Reserved", value: viewModel.daysReserved)
                                    DayInfoRow(title: "Days To Plan", value: viewModel.daysToPlan)
                                }
                                .padding(.leading, 20)
                            }
                            .padding(.leading, 20)
                        }
                    } else {
                        DayInfoRow(title: "Days Left", value: viewModel.daysLeft)
                            .fontWeight(.bold)
                            .font(.title2)
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

    private static func dayStr(for number: Float) -> String {
        (number == 1) ? "day" : "days"
    }

    struct DayInfoRow: View {
        let title: String
        let value: Float

        var body: some View {
            Text("\(title): \(value, format: Formatters.oneDPFormat) \(DaysStatsView.dayStr(for: value))")
        }
    }
}

#Preview {
    DaysStatsView(viewModel: .init(modelContext: .inMemory, currentDate: Date()), year: 2024)
}
