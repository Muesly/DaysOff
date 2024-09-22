//
//  YearStartingDaysModel.swift
//  DaysOff
//
//  Created by Tony Short on 22/09/2024.
//

import Foundation
import SwiftData

@Model
final class YearStartingDaysModel {
    @Attribute(.unique) var year: Int
    var entitledDays: Float
    var kDays: Float

    init(year: Int,
         entitledDays: Float,
         kDays: Float) {
        self.year = year
        self.entitledDays = entitledDays
        self.kDays = kDays
    }
}
