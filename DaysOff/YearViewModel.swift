//
//  YearViewModel.swift
//  DaysOff
//
//  Created by Tony Short on 21/09/2024.
//

import Foundation

final class YearViewModel {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM YYYY"
        return dateFormatter
    }

    static var oneDPFormat: FloatingPointFormatStyle<Float> {
        .number.precision(.fractionLength(0...1))
    }
}
