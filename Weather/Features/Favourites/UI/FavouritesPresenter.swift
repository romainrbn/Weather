//
//  FavouritesPresenter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit
import SwiftUI
import MapKit

final class FavouritesPresenter {
    struct State {
        var favouriteDTOs: [FavouriteItemDTO] = []
        var currentItems: [FavouriteViewDescriptor] = []
        var searchQuery: String = ""
    }

    private let dependencies: FavouriteDependencies
    private let itemsRefresher: FavouriteWeatherRefresher
    private(set) weak var viewContract: FavouritesViewContract?

    private var loadDataTask: Task<Void, Error>?
    private var favouriteStreamTask: Task<Void, Never>?

    var state = State()

    init(
        dependencies: FavouriteDependencies,
        viewContract: FavouritesViewContract
    ) {
        self.dependencies = dependencies
        self.viewContract = viewContract
        self.itemsRefresher = FavouriteWeatherRefresher(store: dependencies.favouriteStore)

        observeFavouritesStream()
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
                let latitude = 48.866667
                let longitude = 2.333333

                var dto = FavouriteItemDTO(
                    identifier: UUID().uuidString,
                    latitude: latitude,
                    longitude: longitude,
                    timezone: .current,
                    locationName: "Paris",
                    currentWeather: nil,
                    todayTemperaturesRange: nil
                )

                dto = try await itemsRefresher.refresh(dto)

                try await dependencies.favouriteStore.createFavourite(
                    from: dto
                )

                let favourites = try await dependencies.favouriteStore.fetchFavourites()

                state.favouriteDTOs = favourites
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
        let newContent = FavouritesViewContentMapper.map(state)
        state.currentItems = newContent.items
        viewContract?.display(newContent)
    }

    // MARK: - User Actions

    @MainActor
    func didSelectItem(_ item: FavouriteViewDescriptor) {
        guard let associatedDTO = state.favouriteDTOs.first(where: { $0.identifier == item.identifier }) else {
            return
        }
        let module = ForecastDetailModule(
            input: ForecastDetailInput(
                latitude: associatedDTO.latitude,
                longitude: associatedDTO.longitude,
                currentWeather: associatedDTO.currentWeather
            ),
            dependencies: ForecastDetailDependencies(
                favouriteStore: dependencies.favouriteStore,
                forecastStore: dependencies.forecastStore
            )
        )

        viewContract?.present(module.viewController, animated: true)
    }

    @MainActor
    func didTapUseCurrentLocationButton() {

    }

    @MainActor
    func didTapSettingsButton() {
        viewContract?.present(
            UIHostingController(rootView: UserPreferencesView()),
            animated: true
        )
    }

    /// Force refresh the data when the user has pulled to refresh
    @MainActor
    func didPullToRefresh() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            let freshDTOs = try await itemsRefresher.refresh(state.favouriteDTOs)
            state.favouriteDTOs = freshDTOs

            await MainActor.run {
                self.updateView()
            }
        }
    }

    @MainActor
    func reorderFavourites(newOrder: [FavouriteViewDescriptor]) {
        let identifiers = newOrder.map(\.identifier)
        let reorderedDTOs = identifiers.compactMap { id in
            state.favouriteDTOs.first(where: { $0.identifier == id })
        }

        state.favouriteDTOs = reorderedDTOs

        Task(priority: .utility) { [weak self] in
            do {
                try await self?.dependencies.favouriteStore.updateFavouriteSortOrder(identifiersInOrder: identifiers)

                await MainActor.run {
                    self?.updateView()
                }
            } catch {
                // Fail
            }
        }
    }

    @MainActor
    func removeFavourite(_ item: FavouriteViewDescriptor) {
        guard
            let associatedDTO = state.favouriteDTOs.first(
                where: { $0.identifier == item.identifier }
            )
        else {
            return
        }
        
        Task(priority: .userInitiated) { [weak self] in
            do {
                try await self?.dependencies.favouriteStore.removeFavourite(associatedDTO)
            } catch {
                // Display cannot remove item error
            }
        }
    }

    // MARK: - Observation

    private func observeFavouritesStream() {
        favouriteStreamTask = Task { [weak self] in
            guard let self else { return }
            for await change in dependencies.favouriteStore.favouritesChangeStream() {
                switch change {
                case .added(let dto):
                    guard state.favouriteDTOs.contains(dto) == false else { return }

                    state.favouriteDTOs.append(dto)
                case .removed(let dto):
                    state.favouriteDTOs.removeAll(where: { $0 == dto })
                }

                await MainActor.run {
                    self.updateView()
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
