//
//  HomePresenter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

final class HomePresenter {
    struct Dependencies {

    }

    struct State {
        var locationItems: [HomeLocationItem] = []
    }

    private let dependencies: Dependencies
    private(set) weak var viewContract: HomeViewContract?

    private var loadDataTask: Task<Void, Error>?

    var state = State()

    init(
        dependencies: Dependencies,
        viewContract: HomeViewContract
    ) {
        self.dependencies = dependencies
        self.viewContract = viewContract
    }

    /// Starts the fetching of all the data, and displays it!
    func loadData() {
        if loadDataTask?.isCancelled == false {
            Log.log("Tried to load the data while already loading.")
            loadDataTask?.cancel()
        }

        loadDataTask = Task(priority: .userInitiated) { [weak self] in
            try Task.checkCancellation()
            guard let self else { return }

            // Load data

            state.locationItems = [
                .init(locationName: "Paris", currentWeather: "Cloudy"),
                .init(locationName: "London", currentWeather: "Rain"),
                .init(locationName: "Los Angeles", currentWeather: "Sunny"),
                .init(locationName: "New York", currentWeather: "Stormy"),
                .init(locationName: "New Delhi", currentWeather: "Polluted"),
                .init(locationName: "San Francisco", currentWeather: "Foggy"),
                .init(locationName: "Cupertino", currentWeather: "Sunny"),
            ]

            await MainActor.run {
                self.updateView()
            }
        }
    }

    @MainActor
    private func updateView() {
        viewContract?.display(HomeContentMapper.map(state))
    }
}
