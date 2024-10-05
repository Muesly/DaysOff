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
    let onDelete: ((DayOffModel) -> Void)

    var body: some View {
        Section {
            ForEach(daysOff) {
                Text("\(Formatters.dateFormatter.string(from: $0.date)) - \($0.type.dayLength, format: Formatters.oneDPFormat) day")
                    .foregroundStyle(colour)
            }
            .onDelete(perform: deleteDayOff)
            .id(heading)
        } header: {
            Text(heading)
        }
        .listRowBackground(Color.backgroundPrimary)
    }

    private func deleteDayOff(offsets: IndexSet) {
        if let offset = offsets.first {
            withAnimation {
                onDelete(daysOff[offset])
            }
        }
    }
}

#Preview {
    List {
        DaysOffSection(heading: "This Month", colour: .black, daysOff: Binding(get: { [DayOffModel(date: Date(), type: .halfDay)] }, set: { _ in }), onDelete: { _ in })
    }
}
