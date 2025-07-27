//
//  LiveFavouriteLocalRepository.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

protocol FavouriteLocalRepository {
    func createDBFavourite(
        latitude: Double,
        longitude: Double,
        latestTemperature: Int,
        maxTemperature: Int,
        minTemperature: Int,
        timeZone: TimeZone
    ) async throws

    func deleteDBFavourite(
        identifier: UUID
    ) async throws
}

struct LiveFavouriteLocalRepository: FavouriteLocalRepository {

    private let manager: WeatherManager

    init(manager: WeatherManager = .shared) {
        self.manager = manager
    }

    func createDBFavourite(
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
            favourite.localIdentifier = UUID()
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

    func deleteDBFavourite(identifier: UUID) async throws {
        try await FavouriteDeleteRequest()
            .setFavouriteIdentifier(identifier)
            .setFetchLimit(1)
            .execute()
    }
}
