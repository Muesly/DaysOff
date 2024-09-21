//
//  EditStartingTotalsView.swift
//  DaysOff
//
//  Created by Tony Short on 21/09/2024.
//

import SwiftUI

struct EditStartingNumDaysView: View {
    @Binding var entitledDays: Float
    @Binding var kDays: Float

    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text("Entitled Days")
                    .padding(5)
                Text("K Days")
                    .padding(5)
            }
            VStack(alignment: .leading) {
                TextField("", value: $entitledDays, formatter: NumberFormatter()) // Updated to NumberFormatter()
                    .keyboardType(.numberPad)
                    .padding(5)
                    .border(Color.black, width: 1)
                    .frame(width: 40)
                TextField("", value: $kDays, formatter: NumberFormatter()) // Updated to NumberFormatter()
                    .keyboardType(.numberPad)
                    .padding(5)
                    .border(Color.black, width: 1)
                    .frame(width: 40)
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Edit Starting Days")
    }
}

#Preview {
    EditStartingNumDaysView(entitledDays: Binding(get: {
        26
    }, set: { _ in }),
                           kDays: Binding(get: { 5 }, set: { _ in }))
}

extension Formatter {
    static var integer: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        return formatter
    }
}
