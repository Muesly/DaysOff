//
//  DayOffModel.swift
//  DaysOff
//
//  Created by Tony Short on 14/09/2024.
//

import Foundation
import SwiftData

enum DayOffType: Codable {
    case fullDay
    case halfDay

    var dayLength: Float {
        switch self {
        case .fullDay: 1
        case .halfDay: 0.5
        }
    }
}

@Model
final class DayOffModel {
    @Attribute(.unique) var date: Date
    var type: DayOffType

    init(date: Date, type: DayOffType) {
        self.date = date
        self.type = type
    }
}
