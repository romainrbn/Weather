//
//  LiveFavouriteLocalRepository.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

protocol FavouriteLocalRepository {
    func createDBFavorite(
        latitude: Double,
        longitude: Double,
        latestTemperature: Int,
        maxTemperature: Int,
        minTemperature: Int,
        timeZone: TimeZone
    ) async throws
}

struct LiveFavouriteLocalRepository: FavouriteLocalRepository {

    private let manager: WeatherManager

    init(manager: WeatherManager = .shared) {
        self.manager = manager
    }

    func createDBFavorite(
        latitude: Double,
        longitude: Double,
        latestTemperature: Int,
        maxTemperature: Int,
        minTemperature: Int,
        timeZone: TimeZone
    ) async throws {
        let context = manager.backgroundContext
        try await context.perform {
            let favourite = DBFavorite(context: context)
            favourite.id = UUID()
            favourite.latitude = latitude
            favourite.longitude = longitude
            favourite.timezoneIdentifier = timeZone.identifier
            favourite.latestUpdate = .now
            favourite.temperature = Int16(latestTemperature)
            favourite.temperatureMin = Int16(minTemperature)
            favourite.temperatureMax = Int16(maxTemperature)

            try context.save()
        }
    }
}
