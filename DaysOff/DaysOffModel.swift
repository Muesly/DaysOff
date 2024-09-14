//
//  DaysOffModel.swift
//  DaysOff
//
//  Created by Tony Short on 14/09/2024.
//

import Foundation

@Observable
class DaysOffModel {
    var numDaysToTake: Float
    private static let defaultDaysToTake: Float = 26

    init() {
        numDaysToTake = Self.defaultDaysToTake
    }

    func takeDay() {
        numDaysToTake -= 1
    }

    func takeHalfDay() {
        numDaysToTake -= 0.5
    }
}
