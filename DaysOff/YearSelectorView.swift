//
//  YearSelectorView.swift
//  DaysOff
//
//  Created by Tony Short on 18/09/2024.
//

import SwiftUI

struct YearSelectorView: View {
    @Binding var year: Int

    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            Button {
                year -= 1
            } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("Previous Year")
            Text("\(year, format: .number.grouping(.never))")
                .font(.title2)
            Button {
                year += 1
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("Next Year")
            Spacer()
        }
    }
}

#Preview {
    YearSelectorView(year: Binding(get: { 2024 }, set: { _ in }))
}
