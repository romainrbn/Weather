//
//  LiveHomeStore.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

protocol HomeStore {
    func createFavorite(
        latitude: Double,
        longitude: Double,
        timeZone: TimeZone
    ) async throws

    func fetchFavorites() async throws -> [FavouriteItemDTO]
}

struct LiveHomeStore: HomeStore {
    func createFavorite(
        latitude: Double,
        longitude: Double,
        timeZone: TimeZone
    ) async throws {
        let manager = WeatherManager.shared
        let context = manager.backgroundContext
        try await context.perform {
            let favorite = DBFavorite(context: context)
            favorite.id = UUID()
            favorite.latitude = latitude
            favorite.longitude = longitude
            favorite.timezoneIdentifier = timeZone.identifier
            try context.save()
        }
    }

    func fetchFavorites() async throws -> [FavouriteItemDTO] {
        let fetchRequest = FetchRequest(
            context: WeatherManager.shared.backgroundContext,
            converter: DBFavouriteConverter()
        )

        return try await fetchRequest.execute()
    }

    func loadWeatherData(for favorites: inout [FavouriteItemDTO]) async throws {
        for index in favorites.indices {
            favorites[index].currentTemperature = 10
        }
    }
}
