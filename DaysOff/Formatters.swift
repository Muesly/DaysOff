//
//  Formatters.swift
//  DaysOff
//
//  Created by Tony Short on 24/09/2024.
//

import Foundation

struct Formatters {
    static var dateFormatter: OrdinalDateFormatter {
        return OrdinalDateFormatter()
    }

    static var oneDPFormat: FloatingPointFormatStyle<Float> {
        .number.precision(.fractionLength(0...1))
    }
}
