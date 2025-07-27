//
//  HomePresenter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit
import SwiftUI
import MapKit

final class HomePresenter {
    struct State {
        var favoritesDTOs: [FavouriteItemDTO] = []
        var searchQuery: String = ""
    }

    private let dependencies: HomeDependencies
    private(set) weak var viewContract: HomeViewContract?

    private var loadDataTask: Task<Void, Error>?
    private var favouriteStreamTask: Task<Void, Never>?

    var state = State()

    init(
        dependencies: HomeDependencies,
        viewContract: HomeViewContract
    ) {
        self.dependencies = dependencies
        self.viewContract = viewContract

        observeFavoritesStream()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        favouriteStreamTask?.cancel()
        favouriteStreamTask = nil
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

            do {
                try await dependencies.store.createFavorite(
                    from: .init(
                        identifier: UUID(),
                        latitude: 45,
                        longitude: 0.4,
                        timezone: .current,
                        locationName: "Paris",
                        currentTemperature: 30,
                        minTemperature: 29,
                        maxTemperature: 32
                    )
                )
                let favorites = try await dependencies.store.fetchFavorites()
                state.favoritesDTOs = favorites
            } catch {
                print("Error!")
            }

            await MainActor.run {
                self.updateView()
            }
        }
    }

    func searchCity(_ query: String, completion: @escaping (WeatherLocalCitySearchResult) -> Void) {
        state.searchQuery = query
        dependencies.citySearchService.debounceSearch(query: query, onResults: completion)
    }

    @MainActor
    private func updateView() {
        viewContract?.display(HomeContentMapper.map(state))
    }

    // MARK: - User Actions

    @MainActor
    func didSelectItem(_ item: FavouriteViewDescriptor) {
        guard let associatedDTO = state.favoritesDTOs.first(where: { $0.identifier == item.identifier }) else {
            return
        }
        let module = ForecastDetailModule(
            input: ForecastDetailInput(from: associatedDTO),
            dependencies: ForecastDetailDependencies(favouriteStore: dependencies.store)
        )

        viewContract?.present(module.viewController, animated: true)
    }

    func didTapUseCurrentLocationButton() {

    }

    @MainActor
    func didTapSettingsButton() {
        viewContract?.present(
            UIHostingController(rootView: UserPreferencesView()),
            animated: true
        )
    }

    func removeFavorite(_ item: FavouriteViewDescriptor) {
        guard
            let associatedDTO = state.favoritesDTOs.first(
                where: { $0.identifier == item.identifier }
            )
        else {
            return
        }
        
        Task {
            do {
                try await dependencies.store.removeFavorite(associatedDTO)
            } catch {
                // Display cannot remove item error
            }
        }
    }

    // MARK: - Observation

    private func observeFavoritesStream() {
        favouriteStreamTask = Task {
            for await change in dependencies.store.favouritesChangeStream() {
                switch change {
                case .added(let dto):
                    guard state.favoritesDTOs.contains(dto) == false else { return }

                    state.favoritesDTOs.append(dto)
                case .removed(let dto):
                    state.favoritesDTOs.removeAll(where: { $0 == dto })
                }

                await MainActor.run {
                    updateView()
                }
            }
        }
    }

    // MARK: - Notifications

    private func registerToNetworkChangeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidConnectBackToNetwork),
            name: UIApplication.applicationDidConnectToNetwork,
            object: nil
        )
    }

    @objc
    private func applicationDidConnectBackToNetwork() {
        // If the user was in a process of querying a city without the internet and comes back online,
        // let's try to search their query again
        guard state.searchQuery.isEmpty == false else { return }
        viewContract?.performCitySearch(state.searchQuery)
    }
}
