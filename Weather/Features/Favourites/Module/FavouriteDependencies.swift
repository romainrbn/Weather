//
//  FavouriteDependencies.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation
import CoreLocation

/// - Note: In a production-scale app, this layer would benefit from a more modular architecture,
/// using protocol-based dependency injection and dedicated modules per feature to ensure clearer separation between business logic and UI concerns.
///
/// For this take-home project, I chose to favor simplicity and readability over abstraction,
/// to keep the structure approachable while still reflecting good practices.
struct FavouriteDependencies {
    let citySearchService: WeatherLocalCitySearchService
    let favouriteStore: FavouriteStore
    let forecastStore: ForecastStore
    let preferencesRepository: UserPreferencesRepository
    let locationManager: LocationManager
}
