//
//  DailyAccumulator.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

/// A small helper to create a global daily weather condition, as the free tier of OpenWeatherMapAPI does not provide
/// conditions for days, only conditions every 3 hours over 5 days.
///
/// We use the "worst" or most important condition for the day to determine the global condition.
/// For example, if a day has both thunderstorm and cloudy conditions,
/// this is more valuable to display the thunderstorm to the user.
///
/// This might not be exactly how weather agencies compute conditions!
struct DailyAccumulator {
    private var sumTemperature: Double = 0
    private var count: Int = 0
    private(set) var worstCondition: WeatherCondition = .unknown

    var report: WeatherReport {
        let averageTemperature = count > 0 ? Int((sumTemperature / Double(count)).rounded()) : 0
        return .init(celsiusTemperature: averageTemperature, condition: worstCondition)
    }

    mutating func add(snapshot: APIWeatherSnapshot) {
        guard let weatherID = snapshot.weather.first?.id else {
            Log.log("Tried to map a snapshot without a weather conditionID.")
            return
        }
        sumTemperature += snapshot.main.temperature
        count += 1

        let condition = APIWeatherConditionMapping.map(weatherID: weatherID)
        if condition.priority > worstCondition.priority {
            worstCondition = condition
        }
    }
}
