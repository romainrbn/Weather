//
//  FavouritesPresenter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit
import SwiftUI
import MapKit

private enum Constants {
    static let minimumTimeBetweenSessionsToRefreshData: TimeInterval = 2 * 60 // 2 minutes
    static let lastUpdateUserDefaultKey: String = "lastUpdate"
}

@MainActor
final class FavouritesPresenter {
    struct State {
        var favouriteDTOs: [FavouriteItemDTO] = []
        var currentItems: [FavouriteViewDescriptor] = []
        var searchQuery: String = ""
        var shouldDisplayLocationButton: Bool = true

        @UserDefault(Constants.lastUpdateUserDefaultKey, defaultValue: Date.now)
        var lastUpdate: Date
    }

    private let dependencies: FavouriteDependencies
    private let itemsRefresher: FavouriteWeatherRefresher
    private let contentMapper: FavouritesViewContentMapper

    private(set) weak var viewContract: FavouritesViewContract?

    private var loadDataTask: Task<Void, Error>?
    private var favouriteStreamTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?

    var state = State()

    init(
        dependencies: FavouriteDependencies,
        viewContract: FavouritesViewContract
    ) {
        self.dependencies = dependencies
        self.viewContract = viewContract
        self.itemsRefresher = FavouriteWeatherRefresher(store: dependencies.favouriteStore)
        self.contentMapper = FavouritesViewContentMapper(preferencesRepository: dependencies.preferencesRepository)

        registerToNotifications()
        observeFavouritesStream()
        state.shouldDisplayLocationButton = !dependencies.locationManager.hasGrantedPermission
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        favouriteStreamTask?.cancel()
        loadDataTask?.cancel()
        refreshTask?.cancel()
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
                let favourites = try await dependencies.favouriteStore.fetchFavourites()
                state.favouriteDTOs = favourites
            } catch {
                await MainActor.run {
                    self.viewContract?.displayError(errorMessage: error.message)
                }
            }

            await MainActor.run {
                self.updateView()
            }
        }
    }

    private func refreshData() {
        if refreshTask?.isCancelled == false {
            refreshTask?.cancel()
        }
        refreshTask = Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                let freshDTOs = try await itemsRefresher.refresh(state.favouriteDTOs)
                state.lastUpdate = .now
                state.favouriteDTOs = freshDTOs

                await MainActor.run {
                    self.updateView()
                }
            } catch {
                await MainActor.run {
                    self.viewContract?.displayError(errorMessage: error.message)
                }
            }
        }
    }

    func searchCity(_ query: String, completion: @escaping (WeatherLocalCitySearchResult) -> Void) {
        state.searchQuery = query
        dependencies.citySearchService.debounceSearch(query: query, onResults: completion)
    }

    private func updateView() {
        let newContent = contentMapper.map(state)
        state.currentItems = newContent.items
        viewContract?.display(newContent)
    }

    // MARK: - User Actions

    func didSelectItem(_ item: FavouriteViewDescriptor) {
        guard let associatedDTO = state.favouriteDTOs.first(where: { $0.identifier == item.identifier }) else {
            return
        }
        presentForecast(associatedDTO: associatedDTO)
    }

    func didTapUseCurrentLocationButton() {
        defer {
            state.shouldDisplayLocationButton = false
            updateView()
        }
        dependencies.locationManager.requestLocation { [weak self] requestResult in
            guard let self else { return }
            switch requestResult {
            case .success(let location):
                findAndOpenCurrentLocation(from: location, isCurrentLocation: true)
            case .failure(let error):
                switch error {
                case .locationNotFound:
                    viewContract?.displayError(errorMessage: "Unable to determine your location for now. Please try again.")
                case .permissionDenied:
                    break
                }
            }
        }
    }

    func showPlacemark(_ result: CLPlacemark, timeZone: TimeZone?, isCurrentLocation: Bool = false) {
        guard let timeZone,
              let locality = result.locality,
              let identifier = result.identifier,
              let latitude = result.location?.coordinate.latitude,
              let longitude = result.location?.coordinate.longitude
        else {
            viewContract?.displayError(errorMessage: "Invalid place. Please try again later")
            return
        }

        let isAlreadyFavourite = state.favouriteDTOs.contains(where: { $0.identifier == identifier })

        var dto = FavouriteItemDTO(
            identifier: identifier,
            latitude: latitude,
            longitude: longitude,
            timezone: timeZone,
            isCurrentLocation: isCurrentLocation,
            locationName: locality,
            isFavourite: isAlreadyFavourite,
            currentWeather: nil
        )

        Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                dto = try await itemsRefresher.refresh(dto)
                state.lastUpdate = .now

                await MainActor.run {
                    self.presentForecast(associatedDTO: dto)
                    self.updateView()
                }
            } catch {
                await MainActor.run {
                    self.viewContract?.displayError(errorMessage: error.message)
                }
            }
        }
    }

    func didTapSettingsButton() {
        viewContract?.present(
            UIHostingController(rootView: UserPreferencesView(userPreferences: dependencies.preferencesRepository)),
            animated: true
        )
    }

    /// Force refresh the data when the user has pulled to refresh
    func didPullToRefresh() {
        refreshData()
    }

    func reorderFavourites(newOrder: [FavouriteViewDescriptor]) {
        let identifiers = newOrder.map(\.identifier)
        let reorderedDTOs = identifiers.compactMap { id in
            state.favouriteDTOs.first(where: { $0.identifier == id })
        }

        guard reorderedDTOs.count == state.favouriteDTOs.count else {
            Log.log("Reorder failed: mismatch between new order and current favourites.")
            return
        }

        state.favouriteDTOs = reorderedDTOs

        Task(priority: .utility) { [weak self] in
            do {
                try await self?.dependencies.favouriteStore.updateFavouriteSortOrder(identifiersInOrder: identifiers)

                await MainActor.run {
                    self?.updateView()
                }
            } catch {
                await MainActor.run {
                    self?.viewContract?.displayError(errorMessage: error.message)
                }
            }
        }
    }

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
                UIAccessibility.post(notification: .announcement, argument: "\(item.locationName) removed.")
            } catch {
                await MainActor.run {
                    self?.viewContract?.displayError(errorMessage: error.message)
                }
            }
        }
    }

    func createForecastViewController(itemIdentifier: String) -> UIViewController? {
        guard let associatedItem = state.favouriteDTOs.first(where: { $0.identifier == itemIdentifier }) else {
            return nil
        }

        return createForecastViewController(associatedDTO: associatedItem)
    }

    func presentForecast(itemIdentifier: String) {
        guard let viewController = createForecastViewController(itemIdentifier: itemIdentifier) else {
            return
        }
        viewContract?.present(viewController, animated: true)
    }

    private func createForecastViewController(associatedDTO: FavouriteItemDTO) -> UIViewController {
        let module = ForecastDetailModule(
            input: ForecastDetailInput(
                associatedItem: associatedDTO
            ),
            dependencies: ForecastDetailDependencies(
                favouriteStore: dependencies.favouriteStore,
                forecastStore: dependencies.forecastStore,
                preferencesRepository: dependencies.preferencesRepository
            )
        )
        return module.viewController
    }

    private func presentForecast(associatedDTO: FavouriteItemDTO) {
        viewContract?.present(createForecastViewController(associatedDTO: associatedDTO), animated: true)
    }

    private func findAndOpenCurrentLocation(from coordinates: CLLocationCoordinate2D, isCurrentLocation: Bool = false) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                let placemark = try await dependencies.locationManager.getPlacemark(from: coordinates)

                await MainActor.run {
                    self.showPlacemark(placemark, timeZone: placemark.timeZone, isCurrentLocation: isCurrentLocation)
                }
            } catch {
                await MainActor.run {
                    self.viewContract?.displayError(errorMessage: error.message)
                }
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
                    if let existingDTOIndex = state.favouriteDTOs.firstIndex(where: { $0.identifier == dto.identifier }) {
                        state.favouriteDTOs[existingDTOIndex].isFavourite = true
                        return
                    }
                    state.favouriteDTOs.append(dto)
                case .removed(let dto):
                    state.favouriteDTOs.removeAll(where: { $0.identifier == dto.identifier })
                }

                await MainActor.run {
                    self.updateView()
                }
            }
        }
    }

    // MARK: - Notifications

    private func registerToNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidConnectBackToNetwork),
            name: UIApplication.applicationDidConnectToNetwork,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferredUnitDidChange),
            name: .didReloadUserPreferredUnit,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshDataOnEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
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

    @objc
    private func preferredUnitDidChange() {
        DispatchQueue.main.async { [weak self] in
            // Simply remap the existing items in-place.
            self?.updateView()
        }
    }

    @objc
    private func refreshDataOnEnterForeground() {
        guard Date.now.timeIntervalSince(state.lastUpdate) > Constants.minimumTimeBetweenSessionsToRefreshData else {
            // Avoid making too many API requests if the user exits/comes back to the app often
            updateView()
            return
        }

        refreshData()
    }
}
