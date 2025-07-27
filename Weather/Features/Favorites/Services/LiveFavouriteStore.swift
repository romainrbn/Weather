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
    func loadWeatherData(latitude: Double, longitude: Double) async throws -> APICurrentWeather

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
            let currentWeather = dto.currentWeather,
            let temperaturesRanges = dto.todayTemperaturesRange
        else {
            throw FavouriteStoreError.missingNecessaryData
        }

        try await localRepository.createDBFavourite(
            identifier: dto.identifier,
            locationName: dto.locationName,
            latitude: dto.latitude,
            longitude: dto.longitude,
            latestTemperature: currentWeather.celsiusTemperature,
            maxTemperature: temperaturesRanges.maximumCelsiusTemperature,
            minTemperature: temperaturesRanges.minimumCelsiusTemperature,
            conditionRawValue: currentWeather.condition.rawValue,
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

    func loadWeatherData(latitude: Double, longitude: Double) async throws -> APICurrentWeather {
        return try await remoteRepository.loadCurrentWeather(
            latitude: latitude,
            longitude: longitude
        )
    }
}
