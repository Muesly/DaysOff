//
//  EditStartingNumDaysView.swift
//  DaysOff
//
//  Created by Tony Short on 21/09/2024.
//

import SwiftUI

struct EditStartingNumDaysView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var entitledDays: Float
    @State var editedEntitledDays: Float

    init(entitledDays: Binding<Float>) {
        self._entitledDays = entitledDays
        self.editedEntitledDays = entitledDays.wrappedValue
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    HStack {
                        HStack {
                            Spacer()
                            Text("Entitled Days")
                        }
                        .frame(width: geometry.size.width / 2, height: 40)
                        HStack {
                            TextField("Entitled Days", value: $editedEntitledDays, formatter: Formatter.decimal)
                                .keyboardType(.decimalPad)
                                .padding(5)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Spacer()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        entitledDays = editedEntitledDays
                        dismiss()
                    }
                }
            }
            .padding()
            .navigationTitle("Edit Starting Days")
        }
    }
}

#Preview {
    EditStartingNumDaysView(entitledDays: Binding(get: {
        26
    }, set: { _ in }))
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
