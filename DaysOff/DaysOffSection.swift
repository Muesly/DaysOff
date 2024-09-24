//
//  DaysOffSection.swift
//  DaysOff
//
//  Created by Tony Short on 21/09/2024.
//

import Foundation
import SwiftUI

struct DaysOffSection: View {
    @Environment(\.modelContext) private var modelContext

    let heading: String
    let colour: Color
    @Binding var daysOff: [DayOffModel]

    var body: some View {
        Section {
            ForEach(daysOff) {
                Text("\(YearViewModel.dateFormatter.string(from: $0.date)) - \($0.type.dayLength, format: YearViewModel.oneDPFormat) day")
                    .foregroundStyle(colour)
            }
            .onDelete(perform: deleteDayOff)
        } header: {
            Text(heading)
        }
        .listRowBackground(Color.backgroundPrimary)
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
    List {
        DaysOffSection(heading: "This Month", colour: .black, daysOff: Binding(get: { [DayOffModel(date: Date(), type: .halfDay)] }, set: { _ in }))
    }
}
