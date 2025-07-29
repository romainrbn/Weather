//
//  APIWeatherConditionMapping.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum APIWeatherConditionCode {
    case range(ClosedRange<Int>)
    case exact(Int)

    func contains(_ value: Int) -> Bool {
        switch self {
        case .range(let range):
            return range.contains(value)
        case .exact(let exactValue):
            return value == exactValue
        }
    }
}

struct APIWeatherConditionMapping {
    private let code: APIWeatherConditionCode
    private let condition: WeatherCondition

    private init(code: APIWeatherConditionCode, condition: WeatherCondition) {
        self.code = code
        self.condition = condition
    }
    private static let minimumRange: Int = 200
    private static let maximumRange: Int = 899

    static let all: [APIWeatherConditionMapping] = [
        APIWeatherConditionMapping(code: .range(200...299), condition: .thunderstorm),
        APIWeatherConditionMapping(code: .range(300...399), condition: .drizzle),
        APIWeatherConditionMapping(code: .range(500...599), condition: .rain),
        APIWeatherConditionMapping(code: .range(600...699), condition: .snow),
        APIWeatherConditionMapping(code: .range(700...799), condition: .atmosphere),
        APIWeatherConditionMapping(code: .exact(800), condition: .clear),
        APIWeatherConditionMapping(code: .range(801...899), condition: .clouds)
    ]

    static func map(weatherID: Int) -> WeatherCondition {
        guard weatherID >= minimumRange && weatherID <= maximumRange else {
            return .unknown
        }

        for mapping in all {
            if mapping.code.contains(weatherID) {
                return mapping.condition
            }
        }

        return .unknown
    }
}
