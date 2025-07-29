//
//  LiveFavouriteRemoteRepository.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

protocol FavouriteRemoteRepository {
    func loadCurrentWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> APICurrentWeather
}

struct LiveFavouriteRemoteRepository: FavouriteRemoteRepository {
    private let router: Router

    init(router: Router = LiveRouter()) {
        self.router = router
    }

    func loadCurrentWeather(latitude: Double, longitude: Double) async throws -> APICurrentWeather {
        let route = CurrentWeatherRoute(inputParameters: [
            "lat": "\(latitude)",
            "lon": "\(longitude)",
            "appid": Secret.apiKey,
            "units": "metric"
        ])
        return try await router.performRequest(route)
    }
}
