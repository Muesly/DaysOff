//
//  TakeDaysView.swift
//  DaysOff
//
//  Created by Tony Short on 14/10/2024.
//

import Foundation

import SwiftUI

struct TakeDaysView: View {
    let viewModel: TakeDaysViewModel = .init()

    var body: some View {
        VStack {
            Text(viewModel.currentMonthStr)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(.backgroundPrimary))
                .foregroundColor(.foregroundPrimary)
        }
    }
}

#Preview {
    TakeDaysView()
}

class TakeDaysViewModel {
    let currentDate: Date = Date()
    let dateFormatter: DateFormatter

    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yy"
        self.dateFormatter = dateFormatter
    }

    var currentMonthStr: String {
        dateFormatter.string(from: currentDate)
    }
}
