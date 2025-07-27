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
    func removeFavorite(_ dto: FavouriteItemDTO) async throws

    func favouritesChangeStream() -> AsyncStream<FavouriteChange>
}

enum FavouriteStoreError: LocalizedError {
    case missingNecessaryData
}

final class LiveFavouriteStore: FavouriteStore {

    private let localRepository: FavouriteLocalRepository
    private let remoteRepository: FavouriteRemoteRepository

    private var continuation: AsyncStream<FavouriteChange>.Continuation?

    init(
        localRepository: FavouriteLocalRepository,
        remoteRepository: FavouriteRemoteRepository
    ) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }

    func favouritesChangeStream() -> AsyncStream<FavouriteChange> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }

    // MARK: CRUD Favourites

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

        try await localRepository.createDBFavourite(
            latitude: dto.latitude,
            longitude: dto.longitude,
            latestTemperature: currentTemperature,
            maxTemperature: maxTemperature,
            minTemperature: minTemperature,
            timeZone: dto.timezone
        )

        continuation?.yield(.added(dto))
    }

    func fetchFavorites() async throws -> [FavouriteItemDTO] {
        let fetchRequest = FetchRequest(
            context: WeatherManager.shared.backgroundContext,
            converter: DBFavouriteConverter()
        )

        let results = try await fetchRequest.execute()

        return results
    }

    func removeFavorite(_ dto: FavouriteItemDTO) async throws {
        try await localRepository.deleteDBFavourite(identifier: dto.identifier)
        continuation?.yield(.removed(dto))
    }

    func loadWeatherData(for favorites: inout [FavouriteItemDTO]) async throws {
        // TODO: Task group for parallelizaiton
        for index in favorites.indices {
            var favorite = favorites[index]

            let currentWeather = try await remoteRepository.loadCurrentWeather(
                latitude: favorite.latitude,
                longitude: favorite.longitude
            )

            favorite.currentTemperature = Int(currentWeather.mainInfo.temperature)
            favorite.minTemperature = Int(currentWeather.mainInfo.minTemperature)
            favorite.maxTemperature = Int(currentWeather.mainInfo.maxTemperature)
        }
    }
}
