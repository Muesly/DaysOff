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
    var dateToTake: Date
    private static let numDaysKey = "Num Days Left"
    private static let defaultDaysToTake: Float = 26

    init(currentDate: Date = Date()) {
        if let savedNumDaysToTake = UserDefaults.standard.value(forKey: Self.numDaysKey) as? Float {
            numDaysToTake = savedNumDaysToTake
        } else {
            numDaysToTake = Self.defaultDaysToTake
        }

        dateToTake = currentDate
    }

    func takeDay() {
        takeDay(amount: 1)
    }

    func takeHalfDay() {
        takeDay(amount: 0.5)
    }

    private func takeDay(amount: Float) {
        numDaysToTake -= amount
        UserDefaults.standard.set(numDaysToTake, forKey: Self.numDaysKey)
    }
}
