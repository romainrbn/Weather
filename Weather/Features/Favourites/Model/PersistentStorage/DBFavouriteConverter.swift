//
//  DBFavouriteConverter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum DBConverterError: Error {
    case missingMandatoryData
}

struct DBFavouriteConverter: DTOConverter {
    func convert(_ object: DBFavourite) throws -> FavouriteItemDTO {
        guard
            let id = object.localIdentifier,
            let timezoneIdentifier = object.timezoneIdentifier,
            let timezone = TimeZone(identifier: timezoneIdentifier),
            let locationName = object.locationName,
            let conditionName = object.conditionName
        else {
            throw DBConverterError.missingMandatoryData
        }

        return FavouriteItemDTO(
            identifier: id,
            latitude: object.latitude,
            longitude: object.longitude,
            timezone: timezone,
            sortOrder: Int(object.sortOrder),
            locationName: locationName,
            isFavourite: true,
            currentWeather: createCurrentWeatherObject(
                temperature: object.temperature,
                temperatureMin: object.temperatureMin,
                temperatureMax: object.temperatureMax,
                rawCondition: object.condition,
                conditionName: conditionName
            )
        )
    }

    private func createCurrentWeatherObject(
        temperature: Int16,
        temperatureMin: Int16,
        temperatureMax: Int16,
        rawCondition: Int16,
        conditionName: String
    ) -> WeatherReport? {
        guard let condition = WeatherCondition(rawValue: Int(rawCondition)) else {
            return nil
        }

        return WeatherReport(
            celsiusTemperature: Int(temperature),
            feelsLikeTemperature: nil,
            condition: condition,
            temperatureRanges: CurrentDayTemperatureRange(
                minimumCelsiusTemperature: Int(temperatureMin),
                maximumCelsiusTemperature: Int(temperatureMax)
            ),
            conditionName: conditionName
        )
    }
}
