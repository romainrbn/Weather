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
            "appid": "4aa698cc2572f540f79280272d0461c6",
            "units": "metric"
        ])
        return try await router.performRequest(route)
    }
}
