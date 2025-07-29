//
//  ForecastRemoteRepository.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

protocol ForecastRemoteRepository {
    func loadForecast(latitude: Double, longitude: Double) async throws -> APIWeatherForecast
}

struct LiveForecastRemoteRepository: ForecastRemoteRepository {
    private let router: Router

    init(router: Router = LiveRouter()) {
        self.router = router
    }

    func loadForecast(latitude: Double, longitude: Double) async throws -> APIWeatherForecast {
        let route = GetForecastRoute(
            inputParameters: [
                "lat": "\(latitude)",
                "lon": "\(longitude)",
                "appid": Secret.apiKey,
                "units": "metric"
            ]
        )
        return try await router.performRequest(route)
    }
}
