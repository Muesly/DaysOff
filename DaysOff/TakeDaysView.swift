//
//  TakeDaysView.swift
//  DaysOff
//
//  Created by Tony Short on 14/10/2024.
//

import Foundation

import SwiftUI

struct TakeDaysView: View {
    @Binding var isPresented: Bool
    @Binding var selectedRange: DateRange?

    let viewModel: TakeDaysViewModel
    let columns: [GridItem] = [GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40))]

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                Spacer()
                Button("Save") {
                    selectedRange = viewModel.dateRange
                    isPresented = false
                }
                .padding()
            }
            HStack(alignment: .center) {
                Spacer()
                Button {
                    withAnimation(.none) {
                        viewModel.moveToPreviousMonth()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Previous Month")
                Text(viewModel.currentMonthStr)
                    .padding(.horizontal, 10)
                    .frame(width: 100)
                    .font(.title3)
                Button {
                    withAnimation(.none) {
                        viewModel.moveToNextMonth()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .accessibilityLabel("Next Month")
                Spacer()
            }
            LazyVGrid(columns: columns) {
                ForEach(viewModel.daysOfWeek) { dayOfWeek in
                    Text(dayOfWeek.dayStr)
                        .bold()
                        .frame(width: 30)
                        .padding(5)
                }
                ForEach(0 ..< viewModel.numLeadingEmptyItems, id: \.self) { _ in
                    Text("")
                        .padding(5)
                }
                ForEach(1 ... viewModel.daysInFocusedMonth, id: \.self) { day in
                    Button {
                        viewModel.selectDay(day: day)
                    } label: {
                        Text("\(day)")
                    }
                    .padding(5)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.foregroundPrimary)
                    .background(viewModel.isDaySelected(day) ? Color.backgroundSecondary : Color.backgroundPrimary)
                }
            }
            .padding()
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(.backgroundPrimary))
        .padding()
    }
}

#Preview {
    TakeDaysView(isPresented: .constant(true), selectedRange: .constant(nil), viewModel: .init(currentDate: Date()))
}
