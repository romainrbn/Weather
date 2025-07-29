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
    let isCurrentLocation: Bool
    var sortOrder: Int?
    var locationName: String
    var isFavourite: Bool
    var currentWeather: WeatherReport?

    init(
        identifier: String,
        latitude: Double,
        longitude: Double,
        timezone: TimeZone,
        isCurrentLocation: Bool = false,
        sortOrder: Int? = nil,
        locationName: String,
        isFavourite: Bool,
        currentWeather: WeatherReport?
    ) {
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.isCurrentLocation = isCurrentLocation
        self.sortOrder = sortOrder
        self.locationName = locationName
        self.isFavourite = isFavourite
        self.currentWeather = currentWeather
    }
}

extension FavouriteItemDTO {
    mutating func apply(weatherData: APICurrentWeather) {
        guard let mainWeather = weatherData.weather.first else { return }

        self.currentWeather = WeatherReport(
            celsiusTemperature: Int(weatherData.mainInfo.temperature.rounded()),
            feelsLikeTemperature: Int(weatherData.mainInfo.feelsLike.rounded()),
            condition: APIWeatherConditionMapping.map(weatherID: mainWeather.id),
            temperatureRanges: .init(
                minimumCelsiusTemperature: Int(weatherData.mainInfo.minTemperature.rounded()),
                maximumCelsiusTemperature: Int(weatherData.mainInfo.maxTemperature.rounded())
            ),
            conditionName: mainWeather.description
        )
    }
}
