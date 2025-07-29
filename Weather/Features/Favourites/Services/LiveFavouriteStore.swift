//
//  LiveFavouriteStore.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

/// The store orchestrates access to remote and local data sources.
///
/// This design might seem more elaborate than required for a 2 screens app,
/// but it reflects the kind of scalable and testable architecture I would apply
/// in a production environment.
protocol FavouriteStore {
    func createFavourite(from dto: FavouriteItemDTO) async throws
    func fetchFavourites() async throws -> [FavouriteItemDTO]
    func removeFavourite(_ dto: FavouriteItemDTO) async throws
    func loadWeatherData(latitude: Double, longitude: Double) async throws -> APICurrentWeather
    func updateFavouriteSortOrder(identifiersInOrder: [String]) async throws

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

    func createFavourite(
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
            conditionName: currentWeather.conditionName,
            timeZone: dto.timezone
        )

        continuation?.yield(.added(dto))
    }

    func fetchFavourites() async throws -> [FavouriteItemDTO] {
        return try await localRepository.fetchFavourites()
    }

    func removeFavourite(_ dto: FavouriteItemDTO) async throws {
        try await localRepository.deleteDBFavourite(identifier: dto.identifier)
        continuation?.yield(.removed(dto))
    }

    func loadWeatherData(latitude: Double, longitude: Double) async throws -> APICurrentWeather {
        return try await remoteRepository.loadCurrentWeather(
            latitude: latitude,
            longitude: longitude
        )
    }

    func updateFavouriteSortOrder(identifiersInOrder: [String]) async throws {
        try await localRepository.persistFavouriteOrder(identifiersInOrder: identifiersInOrder)
    }
}
