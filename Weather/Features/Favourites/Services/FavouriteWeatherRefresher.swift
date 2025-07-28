//
//  FavouriteWeatherRefresher.swift
//  Weather
//
//  Created by Romain Rabouan on 7/28/25.
//

import Foundation

/// Orchestrates parallel weather refresh for a batch of favourites.
struct FavouriteWeatherRefresher {
    private let store: FavouriteStore

    init(store: FavouriteStore) {
        self.store = store
    }

    /// Refreshes one favourite item by fetching its weather and applying it.
    func refresh(_ item: FavouriteItemDTO) async throws -> FavouriteItemDTO {
        let data = try await store.loadWeatherData(
            latitude: item.latitude,
            longitude: item.longitude
        )
        var copy = item
        copy.apply(weatherData: data)
        return copy
    }

    /// Refreshes a batch of items.
    func refresh(_ items: [FavouriteItemDTO]) async throws -> [FavouriteItemDTO] {
        try await withThrowingTaskGroup(
            of: (Int, FavouriteItemDTO).self,
            returning: [FavouriteItemDTO].self
        ) { group in
            for (index, item) in items.enumerated() {
                group.addTask {
                    let updatedItem = try await self.refresh(item)
                    return (index, updatedItem)
                }
            }

            var updatedItems = items
            for try await (index, newDTO) in group {
                updatedItems[index] = newDTO
            }

            return updatedItems
        }
    }
}
