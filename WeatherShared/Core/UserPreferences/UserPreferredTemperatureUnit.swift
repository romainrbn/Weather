//
//  UserPreferredTemperatureUnit.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum UserPreferredTemperatureUnit: Int, CaseIterable {
    case celsius
    case fahrenheit

    var title: String {
        switch self {
        case .celsius:
            return "Celsius (°C)"
        case .fahrenheit:
            return "Fahrenheit (°F)"
        }
    }

    static var defaultForCurrentLocale: UserPreferredTemperatureUnit {
        let systemTemperature = UnitTemperature(forLocale: .current, usage: .weather)
        switch systemTemperature {
        case .celsius, .kelvin:
            return .celsius
        case .fahrenheit:
            return .fahrenheit
        default:
            return .celsius
        }
    }
}
