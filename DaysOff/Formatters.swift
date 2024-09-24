//
//  Formatters.swift
//  DaysOff
//
//  Created by Tony Short on 24/09/2024.
//

import Foundation

struct Formatters {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM YYYY"
        return dateFormatter
    }

    static var oneDPFormat: FloatingPointFormatStyle<Float> {
        .number.precision(.fractionLength(0...1))
    }
}
