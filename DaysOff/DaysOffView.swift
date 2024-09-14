//
//  DaysOffView.swift
//  DaysOff
//
//  Created by Tony Short on 14/09/2024.
//

import SwiftUI
import SwiftData

struct DaysOffView: View {
    @State var model: DaysOffModel

    var body: some View {
        NavigationStack {
            VStack {
                Text("Days Left: \(model.numDaysToTake, format: .number.precision(.fractionLength(0...1))) days")
                DatePicker(
                        "Day To Take",
                        selection: $model.dateToTake,
                        displayedComponents: [.date]
                    )
                Button("Take 1 Day") {
                    model.takeDay()
                }
                Button("Take 1/2 Day") {
                    model.takeHalfDay()
                }
            }
            .navigationTitle("Days Off in 2024")
        }
    }
}

#Preview {
    DaysOffView(model: DaysOffModel())
}
