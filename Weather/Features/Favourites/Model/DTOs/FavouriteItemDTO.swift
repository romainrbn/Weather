//
//  FavouriteItemDTO.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct FavouriteItemDTO: Hashable {
    let identifier: String
    let latitude: Double
    let longitude: Double
    let timezone: TimeZone
    var sortOrder: Int?
    var locationName: String
    var currentWeather: WeatherReport?
    var todayTemperaturesRange: CurrentDayTemperatureRange?

    init(
        identifier: String,
        latitude: Double,
        longitude: Double,
        timezone: TimeZone,
        sortOrder: Int? = nil,
        locationName: String,
        currentWeather: WeatherReport?,
        todayTemperaturesRange: CurrentDayTemperatureRange?
    ) {
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.sortOrder = sortOrder
        self.locationName = locationName
        self.currentWeather = currentWeather
        self.todayTemperaturesRange = todayTemperaturesRange
    }
}

extension FavouriteItemDTO {
    mutating func apply(weatherData: APICurrentWeather) {
        guard let mainWeather = weatherData.weather.first else { return }

        self.currentWeather = WeatherReport(
            celsiusTemperature: Int(weatherData.mainInfo.temperature.rounded()),
            condition: APIWeatherConditionMapping.map(weatherID: mainWeather.id)
        )

        self.todayTemperaturesRange = CurrentDayTemperatureRange(
            minimumCelsiusTemperature: Int(weatherData.mainInfo.minTemperature.rounded()),
            maximumCelsiusTemperature: Int(weatherData.mainInfo.maxTemperature.rounded())
        )
    }
}
