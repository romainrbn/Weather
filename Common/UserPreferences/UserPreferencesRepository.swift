//
//  UserPreferencesRepository.swift
//  Weather
//
//  Created by Romain Rabouan on 7/28/25.
//

import Foundation

final class UserPreferencesRepository {
    private enum Keys {
        static let temperatureUnit = "user_preferred_temperature_unit"
        static let shouldDisplayCurrentLocation = "should_display_current_location"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var preferredTemperatureUnit: UserPreferredTemperatureUnit {
        get {
            let rawValue = defaults.integer(forKey: Keys.temperatureUnit)
            return UserPreferredTemperatureUnit(rawValue: rawValue) ?? .systemDefault
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.temperatureUnit)
            NotificationCenter.default.post(name: .didReloadUserPreferredUnit, object: nil)
        }
    }

    var shouldDisplayCurrentLocation: Bool {
        get {
            return defaults.bool(forKey: Keys.shouldDisplayCurrentLocation)
        }
        set {
            defaults.set(newValue, forKey: Keys.shouldDisplayCurrentLocation)
        }
    }
}
