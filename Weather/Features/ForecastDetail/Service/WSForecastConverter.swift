//
//  WSForecastConverter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct WSForecastConverter {
    static func convert(
        cityName: String,
        currentWeather: WeatherReport,
        wsForecast: APIWeatherForecast
    ) -> ForecastDTO {
        let (hourlyConditions, dailyConditions) = ForecastAggregator.makeHourlyAndDaily(
            from: wsForecast.list
        )

        return ForecastDTO(
            cityName: cityName,
            currentWeather: currentWeather,
            hourlyDetailedConditions: hourlyConditions,
            nextDaysDetailedConditions: dailyConditions
        )
    }
}
