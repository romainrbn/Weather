//
//  UserPreferredTemperatureUnit.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum UserPreferredTemperatureUnit: Int, CaseIterable {
    case systemDefault
    case celsius
    case fahrenheit

    var title: String {
        switch self {
        case .systemDefault:
            return "System (\(Self.defaultForCurrentLocale.unitTitle))"
        case .celsius:
            return "Celsius (\(unitTitle))"
        case .fahrenheit:
            return "Fahrenheit (\(unitTitle))"
        }
    }

    var unitTitle: String {
        switch self {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        case .systemDefault:
            assert(false, "Not applicable - Should not happen.")
            return "-"
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
