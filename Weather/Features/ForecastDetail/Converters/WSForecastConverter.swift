//
//  WSForecastConverter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct WSForecastConverter {
    static func convert(
        currentWeather: WeatherReport,
        currentDayTemperatureRanges: CurrentDayTemperatureRange,
        wsForecast: APIWeatherForecast
    ) -> ForecastDTO {
        return ForecastDTO(
            cityName: wsForecast.city.name,
            currentWeather: currentWeather,
            currentDayTemperatureRange: currentDayTemperatureRanges,
            hourlyDetailedConditions: [HourlyForecast],
            nextDaysDetailedConditions: [DailyForecast]
        )
    }

    private static func createHourlyForecast() {

    }
}
