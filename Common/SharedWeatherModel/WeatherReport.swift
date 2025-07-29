//
//  WeatherReport.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct WeatherReport: Hashable {
    let celsiusTemperature: Int
    let feelsLikeTemperature: Int?
    let condition: WeatherCondition
    let temperatureRanges: CurrentDayTemperatureRange?
    let conditionName: String
}
