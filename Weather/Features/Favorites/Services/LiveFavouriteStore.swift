//
//  LiveFavouriteStore.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

protocol FavouriteStore {
    func createFavorite(from dto: FavouriteItemDTO) async throws
    func fetchFavorites() async throws -> [FavouriteItemDTO]
}

enum FavouriteStoreError: LocalizedError {
    case missingNecessaryData
}

struct LiveFavouriteStore: FavouriteStore {

    private let localRepository: FavouriteLocalRepository
    private let remoteRepository: FavouriteRemoteRepository

    init(
        localRepository: FavouriteLocalRepository,
        remoteRepository: FavouriteRemoteRepository
    ) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }

    func createFavorite(
        from dto: FavouriteItemDTO
    ) async throws {
        guard
            let currentTemperature = dto.currentTemperature,
            let minTemperature = dto.minTemperature,
            let maxTemperature = dto.maxTemperature
        else {
            throw FavouriteStoreError.missingNecessaryData
        }

        try await localRepository
            .createDBFavorite(
                latitude: dto.latitude,
                longitude: dto.longitude,
                latestTemperature: currentTemperature,
                maxTemperature: maxTemperature,
                minTemperature: minTemperature,
                timeZone: dto.timezone
            )
    }

    func fetchFavorites() async throws -> [FavouriteItemDTO] {
        let fetchRequest = FetchRequest(
            context: WeatherManager.shared.backgroundContext,
            converter: DBFavouriteConverter()
        )

        return try await fetchRequest.execute()
    }

    func loadWeatherData(for favorites: inout [FavouriteItemDTO]) async throws {
        // TODO: Task group for parallelizaiton
        for index in favorites.indices {
            var favorite = favorites[index]
            let currentWeather = try await remoteRepository.loadCurrentWeather(
                latitude: favorite.latitude,
                longitude: favorite.longitude
            )

            favorites[index].currentTemperature = Int(currentWeather.mainInfo.temperature)
            favorites[index].minTemperature = Int(currentWeather.mainInfo.minTemperature)
            favorites[index].maxTemperature = Int(currentWeather.mainInfo.maxTemperature)
        }
    }
}
