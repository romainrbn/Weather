//
//  FavouriteItemDTO.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct FavouriteItemDTO: Hashable {
    let identifier: UUID
    let latitude: Double
    let longitude: Double
    let timezone: TimeZone
    var locationName: String?
    var currentWeather: WeatherReport?
    var todayTemperaturesRange: CurrentDayTemperatureRange?

    init(
        identifier: UUID,
        latitude: Double,
        longitude: Double,
        timezone: TimeZone,
        locationName: String?,
        currentWeather: WeatherReport?,
        todayTemperaturesRange: CurrentDayTemperatureRange?
    ) {
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.locationName = locationName
        self.currentWeather = currentWeather
        self.todayTemperaturesRange = todayTemperaturesRange
    }
}
