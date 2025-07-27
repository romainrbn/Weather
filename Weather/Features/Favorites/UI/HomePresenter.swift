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

    var state = State()

    init(
        dependencies: HomeDependencies,
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

            let favorites = try await dependencies.store.fetchFavorites()
            state.favoritesDTOs = favorites

            await MainActor.run {
                self.updateView()
            }
        }
    }

    func searchCity(_ query: String, completion: @escaping (WeatherLocalCitySearchResult) -> Void) {
        state.searchQuery = query
        dependencies.citySearchService.debounceSearch(query: query, onResults: completion)
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

    @MainActor
    private func updateView() {
        viewContract?.display(HomeContentMapper.map(state))
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
