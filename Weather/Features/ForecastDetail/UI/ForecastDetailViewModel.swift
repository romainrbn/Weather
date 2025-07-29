//
//  ForecastDetailViewModel.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation
import Combine

enum ForecastDetailError: Error {
    case missingNecessaryData
}

/// For this SwiftUI view, let's use a view model pattern (and not a presenter like for the favourites view, made with UIKit).
/// This aligns well with SwiftUI's declarative paradigm, where views react to state changes.
final class ForecastDetailViewModel: ObservableObject {
    var input: ForecastDetailInput
    private let dependencies: ForecastDetailDependencies
    private let mapper: ForecastViewDescriptorMapper

    @Published var forecast: Loadable<ForecastViewDescriptor> = .loading
    @Published var isFavourite: Bool

    init(input: ForecastDetailInput, dependencies: ForecastDetailDependencies) {
        self.input = input
        self.dependencies = dependencies
        self.isFavourite = input.associatedItem.isFavourite
        self.mapper = ForecastViewDescriptorMapper(preferencesRepository: dependencies.preferencesRepository)
    }

    func loadData() async {
        guard let currentWeather = input.associatedItem.currentWeather else {
            self.forecast = .error(ForecastDetailError.missingNecessaryData)
            return
        }
        do {
            let loadedForecast = try await dependencies.forecastStore.loadForecast(
                latitude: input.associatedItem.latitude,
                longitude: input.associatedItem.longitude,
                cityName: input.associatedItem.locationName,
                currentWeather: currentWeather
            )
            let forecastDescriptor = mapper.map(
                from: loadedForecast,
                timezone: input.associatedItem.timezone
            )
            await MainActor.run {
                self.forecast = .value(forecastDescriptor)
            }
        } catch {
            await MainActor.run {
                self.forecast = .error(error)
            }
        }
    }

    func toggleFavourite() {
        Task(priority: .high) { [weak self] in
            guard let self else { return }
            if input.associatedItem.isFavourite {
                input.associatedItem.isFavourite = false
                try await dependencies.favouriteStore.removeFavourite(input.associatedItem)
            } else {
                input.associatedItem.isFavourite = true
                try await dependencies.favouriteStore.createFavourite(from: input.associatedItem)
            }
            await MainActor.run {
                self.isFavourite.toggle()
            }
        }
    }
}
