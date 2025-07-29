//
//  FavouriteItemDTOTests.swift
//  WeatherTests
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation
import Testing
@testable import Weather

struct FavouriteItemDTOTests {

    @Test("apply(weatherData:) populates currentWeather and todayTemperaturesRange correctly")
    func testApplyWeatherData() throws {
        var dto = try makeDTO(identifier: "123", lat: 51.5098, lon: -0.118, name: "London", timeZoneIdentifier: "Europe/London")

        let id = 800
        let weather = makeWeather(
            id: id,
            temperature: 19.7,
            condition: APIWeatherCondition(
                id: id,
                main: "Clear",
                description: "clear sky",
                icon: "01d"
            ),
            min: 12.1,
            max: 23.4
        )

        dto.apply(weatherData: weather)

        #expect(dto.currentWeather == WeatherReport(
            celsiusTemperature: 20,
            condition: .clear
        ))

        #expect(dto.todayTemperaturesRange == CurrentDayTemperatureRange(
            minimumCelsiusTemperature: 12,
            maximumCelsiusTemperature: 23
        ))
    }

    @Test("apply(weatherData:) does nothing when weather list is empty")
    func testEmptyWeatherListDoesNothing() throws {
        var dto = try makeDTO(identifier: "456", lat: 40.0, lon: -3.0, name: "Madrid", timeZoneIdentifier: "Europe/Madrid")
        let weather = makeWeather(id: 0, condition: nil)

        dto.apply(weatherData: weather)

        #expect(dto.currentWeather == nil)
        #expect(dto.todayTemperaturesRange == nil)
    }

    // MARK: - Private Helpers

    private func makeDTO(
        identifier: String,
        lat: Double,
        lon: Double,
        name: String,
        timeZoneIdentifier: String
    ) throws -> FavouriteItemDTO {
        FavouriteItemDTO(
            identifier: identifier,
            latitude: lat,
            longitude: lon,
            timezone: try #require(TimeZone(identifier: timeZoneIdentifier)),
            locationName: name,
            currentWeather: nil,
            todayTemperaturesRange: nil
        )
    }

    private func makeWeather(
        id: Int,
        temperature: Double = 20.0,
        condition: APIWeatherCondition?,
        min: Double = 10.0,
        max: Double = 25.0
    ) -> APICurrentWeather {
        APICurrentWeather(
            status: 200,
            timestamp: 0,
            coordinates: .init(latitude: 0, longitude: 0),
            weather: [condition].compactMap { $0 },
            mainInfo: APIWeatherMainInfo(
                temperature: temperature,
                feelsLike: temperature,
                minTemperature: min,
                maxTemperature: max,
                pressure: 1010,
                seaLevel: 1010,
                groundLevel: 1000,
                humidity: 50
            ),
            system: .init(sunrise: 0, sunset: 0),
            timezone: 0
        )
    }
}
