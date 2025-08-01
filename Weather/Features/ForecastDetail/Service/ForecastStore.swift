//
//  ForecastStore.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

protocol ForecastStore {
    /**
     Loads the forecast for the provided coordinates.

     Although the OpenWeatherMap API supports querying by city name, it's probably better
     to use latitude and longitude for improved reliability.

     This is because `MKLocalSearch` may return city names that don't exactly
     match those expected by the geocoding version of the API (language, uniqueness, diacritics...),
     leading to inconsistent results.

     For example: "München" -> "Munich", or "San Jose (CA)" -> "San Jose (Costa Rica)"

     In contrast, coordinates always resolve to a valid location, making them a safer
     and more consistent input for forecast requests.
     */
    func loadForecast(
        latitude: Double,
        longitude: Double,
        cityName: String,
        currentWeather: WeatherReport
    ) async throws -> ForecastDTO
}

struct LiveForecastStore: ForecastStore {

    private let repository: ForecastRemoteRepository

    init(repository: ForecastRemoteRepository) {
        self.repository = repository
    }

    func loadForecast(
        latitude: Double,
        longitude: Double,
        cityName: String,
        currentWeather: WeatherReport
    ) async throws -> ForecastDTO {
        let apiModel = try await repository.loadForecast(latitude: latitude, longitude: longitude)
        return APIForecastConverter.convert(
            cityName: cityName,
            currentWeather: currentWeather,
            wsForecast: apiModel
        )
    }
}
