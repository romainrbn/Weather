//
//  ForecastDTO.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct ForecastDTO {
    let cityName: String
    let currentWeather: WeatherReport
    let hourlyDetailedConditions: [HourlyForecast]
    let nextDaysDetailedConditions: [DailyForecast]
}
