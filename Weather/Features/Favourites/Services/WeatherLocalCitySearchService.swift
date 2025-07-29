//
//  WeatherLocalCitySearchService.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation
import MapKit

typealias WeatherLocalCitySearchResult = Result<[MKMapItem], WeatherLocalCitySearchServiceError>

enum WeatherLocalCitySearchServiceError: Error, LocalizedError {
    case networkError
    case mapKitError(_ underlyingError: any Error)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network Error"
        case .mapKitError(let underlyingError):
            return underlyingError.localizedDescription
        }
    }
}

/// A service allowing to search for a city.
///
/// - Important: Normally, we could/should use `MKLocalSearchCompleter`, as it would give us near real-time, debounced suggestions.
/// However, the current API only allows address or POI filtering, and we would need a "hack" to extract only cities.
///
/// The `MKLocalSearch` used here is made for single queries, and will return a single result, but we are sure to only fetch cities.
final class WeatherLocalCitySearchService {
    private var currentDebounceWorkItem: DispatchWorkItem?
    private var currentSearch: MKLocalSearch?

    func debounceSearch(
        query: String,
        delay: TimeInterval = 0.3,
        onResults: @escaping (WeatherLocalCitySearchResult) -> Void
    ) {
        currentDebounceWorkItem?.cancel()
        currentSearch?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            onResults(.success([]))
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            DispatchQueue.global(qos: .userInitiated).async {
                self?.searchCities(query: query) { mapItems in
                    DispatchQueue.main.async {
                        onResults(mapItems)
                    }
                }
            }
        }

        currentDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func searchCities(query: String, completion: @escaping (WeatherLocalCitySearchResult) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(WeatherLocalCitySearchServiceError.networkError))
            return
        }
        currentSearch?.cancel()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        let search = MKLocalSearch(request: request)
        currentSearch = search

        search.start { response, error in
            guard let items = response?.mapItems else {
                completion(.success([]))
                return
            }

            if let error {
                completion(.failure(WeatherLocalCitySearchServiceError.mapKitError(error)))
            }

            let cities = items.filter {
                let placemark = $0.placemark
                return placemark.locality != nil && placemark.subLocality == nil && placemark.thoroughfare == nil
            }

            completion(.success(cities))
        }
    }

    func cancel() {
        currentDebounceWorkItem?.cancel()
        currentSearch?.cancel()
    }
}
