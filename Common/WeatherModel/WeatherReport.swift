//
//  WeatherReport.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct WeatherReport: Hashable {
    let celsiusTemperature: Int
    let condition: WeatherCondition
}
