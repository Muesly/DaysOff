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
                        ZStack {
                            DaySelectionView(type: viewModel.dayOffType(forDay: day))
                            Text("\(day)")
                        }
                    }
                    .padding(5)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.foregroundPrimary)
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

struct DaySelectionView: View {
    let type: DayOffType?

    var body: some View {
        GeometryReader { geometry in
            switch type {
            case .fullDay:
                Color.backgroundSecondary
            case .halfDay:
                ZStack {
                    Color.clear
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        path.move(to: CGPoint(x: 0, y: height))
                        path.addLine(to: CGPoint(x: width, y: 0))
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.addLine(to: CGPoint(x: 0, y: height))
                    }
                }
                .foregroundColor(.backgroundSecondary)
            case .none:
                Color.clear
            }
        }
    }
}
