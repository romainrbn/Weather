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
    private let input: ForecastDetailInput
    private let dependencies: ForecastDetailDependencies

    @Published var forecast: ForecastDTO? = nil

    init(input: ForecastDetailInput, dependencies: ForecastDetailDependencies) {
        self.input = input
        self.dependencies = dependencies
    }

    func loadData() async {
        do {
            let loadedForecast = try await dependencies.forecastStore.loadForecast(
                latitude: input.latitude,
                longitude: input.longitude,
                currentWeather: input.currentWeather
            )
            await MainActor.run {
                self.forecast = loadedForecast
            }
        } catch {
            //display error
            print(error)
        }
//        try await dependencies.
    }
}
