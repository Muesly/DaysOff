//
//  EditStartingNumDaysView.swift
//  DaysOff
//
//  Created by Tony Short on 21/09/2024.
//

import SwiftUI

struct EditStartingNumDaysView: View {
    @Binding var entitledDays: Float
    @Binding var kDays: Float

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        Spacer()
                        Text("Entitled Days")
                    }
                    .frame(width: geometry.size.width / 2, height: 40)
                    HStack {
                        TextField("Entitled Days", value: $entitledDays, formatter: Formatter.decimal)
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .border(Color.black, width: 1)
                            .frame(width: 50)
                        Spacer()
                    }
                }
                HStack {
                    HStack {
                        Spacer()
                        Text("K Days")
                    }
                    .frame(width: geometry.size.width / 2, height: 40)
                    HStack {
                        TextField("K Days", value: $kDays, formatter: Formatter.decimal)
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .border(Color.black, width: 1)
                            .frame(width: 50)
                        Spacer()
                    }
                }
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
    static var decimal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .halfUp
        formatter.numberStyle = .decimal
        return formatter
    }
}
