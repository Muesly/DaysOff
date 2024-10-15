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
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                Spacer()
                Text(viewModel.currentMonthStr)
                    .padding()
                Spacer()
                Button("Save") {
                    selectedRange = viewModel.dateRange
                    isPresented = false
                }
                .padding()
            }
            LazyVGrid(columns: columns) {
                ForEach(viewModel.daysOfWeek) { dayOfWeek in
                    Text(dayOfWeek.dayStr)
                        .bold()
                        .frame(width: 30)
                        .padding(5)
                }
                ForEach(1 ... viewModel.numLeadingEmptyItems, id: \.self) { _ in
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

@Observable
class TakeDaysViewModel {
    let currentDate: Date
    let dateFormatter: DateFormatter
    let daysOfWeek: [DayOfWeek]
    var startDate: Date?

    struct DayOfWeek: Identifiable {
        var id: Int {
            weekDay
        }
        let dayStr: String
        let weekDay: Int
    }

    init(currentDate: Date) {
        self.currentDate = currentDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yy"
        self.dateFormatter = dateFormatter

        self.daysOfWeek = [.init(dayStr: "M", weekDay: 1),
                           .init(dayStr: "T", weekDay: 2),
                           .init(dayStr: "W", weekDay: 3),
                           .init(dayStr: "T", weekDay: 4),
                           .init(dayStr: "F", weekDay: 5),
                           .init(dayStr: "S", weekDay: 6),
                           .init(dayStr: "S", weekDay: 7)]
    }

    var currentMonthStr: String {
        dateFormatter.string(from: currentDate)
    }

    var daysInFocusedMonth: Int {
        NSCalendar.current.range(of: .day, in: .month, for: currentDate)!.count
    }

    var numLeadingEmptyItems: Int {
        let calendar = NSCalendar.current
        let currentMonthComponents = calendar.dateComponents([.month, .year], from: currentDate)
        let dateForFirstDay = calendar.date(from: currentMonthComponents)!
        let dayOfFirstDayOfMonth = calendar.dateComponents([.weekday], from: dateForFirstDay).weekday!
        return dayOfFirstDayOfMonth == 1 ? 6 : dayOfFirstDayOfMonth - 2
    }

    func selectDay(day: Int) {
        let calendar = NSCalendar.current
        var currentMonthComponents = calendar.dateComponents([.month, .year], from: currentDate)
        currentMonthComponents.day = day
        startDate = calendar.date(from: currentMonthComponents)!
    }

    func isDaySelected(_ day: Int) -> Bool {
        guard let startDate else {
            return false
        }
        let calendar = NSCalendar.current
        var currentMonthComponents = calendar.dateComponents([.month, .year], from: startDate)
        currentMonthComponents.day = day
        let date = calendar.date(from: currentMonthComponents)!
        return date == startDate
    }

    var dateRange: DateRange? {
        guard let startDate else {
            return nil
        }
        return DateRange(startDate: startDate, startDayOffType: .fullDay, endDate: nil, endDayOffType: nil)
    }
}
