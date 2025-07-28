//
//  ForecastDetailViewModel.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Combine

/// For this SwiftUI view, let's use a view model pattern (and not a presenter like for the favourites view, made with UIKit).
/// This aligns well with SwiftUI's declarative paradigm, where views react to state changes.
final class ForecastDetailViewModel: ObservableObject {
    let input: ForecastDetailInput
    private let dependencies: ForecastDetailDependencies

    @Published var forecast: ForecastDTO? = nil


    init(input: ForecastDetailInput, dependencies: ForecastDetailDependencies) {
        self.input = input
        self.dependencies = dependencies
    }

    func loadData() async {
        do {
            let loadedForecast = try await dependencies.forecastStore.loadForecast(
                latitude: input.associatedItem.latitude,
                longitude: input.associatedItem.longitude,
                currentWeather: input.associatedItem.currentWeather
            )
            await MainActor.run {
                self.forecast = loadedForecast
            }
        } catch {
            // TODO: display error: IMPORTANT: Filter out URL Session errors to display core data backed info.
            print(error)
        }
    }

    func addToFavourites() {
        Task(priority: .high) { [weak self] in
            guard let self else { return }
            try await dependencies.favouriteStore.createFavourite(from: input.associatedItem)
        }
    }
}
