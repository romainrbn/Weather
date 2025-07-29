//
//  ForecastDetailDependencies.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

struct ForecastDetailDependencies {
    let favouriteStore: FavouriteStore
    let forecastStore: ForecastStore
    let preferencesRepository: UserPreferencesRepository
}
