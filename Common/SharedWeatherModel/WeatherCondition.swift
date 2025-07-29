//
//  WeatherCondition.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

/// See: https://openweathermap.org/weather-conditions
enum WeatherCondition: Int {
    case clear
    case clouds
    case thunderstorm
    case drizzle
    case rain
    case snow
    case atmosphere
    case unknown
}

extension WeatherCondition {
    /// See `DailyAccumulator.swift` for more info and the use of this property.
    var priority: Int {
        switch self {
        case .unknown:
            return 0
        case .clear:
            return 1
        case .clouds:
            return 2
        case .rain:
            return 3
        case .snow:
            return 4
        case .thunderstorm:
            return 5
        case .drizzle:
            return 6
        case .atmosphere:
            return 7
        }
    }
}
