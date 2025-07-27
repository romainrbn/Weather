//
//  FavouritesViewContentMapper.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

/// Creates the content to display on the home view, from the current state of the presenter.
struct FavouritesViewContentMapper {
    static func map(_ state: HomePresenter.State) -> FavouritesViewContent {
        FavouritesViewContent(
            items: buildFavoritesItems(from: state.favoritesDTOs)
        )
    }

    private static func buildFavoritesItems(from items: [FavouriteItemDTO]) -> [FavouriteViewDescriptor] {
        guard !items.isEmpty else {
            return []
        }
        
        return items.compactMap { favouriteItem -> FavouriteViewDescriptor? in
            guard let descriptor = favouriteViewDescriptor(from: favouriteItem) else {
                return nil
            }
            return descriptor
        }
    }

    private static func favouriteViewDescriptor(from favouriteItem: FavouriteItemDTO) -> FavouriteViewDescriptor? {
        guard
            let currentWeather = favouriteItem.currentWeather,
            let temperatureRange = favouriteItem.todayTemperaturesRange
        else {
            return nil
        }

        return FavouriteViewDescriptor(
            identifier: favouriteItem.identifier,
            locationName: favouriteItem.locationName,
            isCurrentLocation: false,
            localFormattedTime: formattedCurrentTime(in: favouriteItem.timezone),
            currentWeather: formattedTemperature(value: currentWeather.celsiusTemperature),
            currentConditionsSymbolName: currentWeather.condition.associatedSystemSymbolName,
            minimumTemperature: formattedTemperature(value: temperatureRange.minimumCelsiusTemperature),
            maximumTemperature: formattedTemperature(value: temperatureRange.maximumCelsiusTemperature)
        )
    }

    private static func formattedCurrentTime(in timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = .autoupdatingCurrent

        return dateFormatter.string(from: Date())
    }

    private static func formattedTemperature(value: Int) -> String {
        UserPreferredUnitConverter().formatValue(
            celsiusTemperatureValue: Double(value),
            unit: .celsius
        )
    }
}

extension WeatherCondition {
    fileprivate var associatedSystemSymbolName: String {
        switch self {
        case .clear:
            return "sun.max.fill"
        case .clouds:
            return "cloud.fill"
        case .thunderstorm:
            return "cloud.bolt.fill"
        case .drizzle:
            return "cloud.drizzle"
        case .rain:
            return "cloud.name"
        case .snow:
            return "cloud.snow"
        case .atmosphere:
            return "sun.dust.fill"
        case .unknown:
            return "cloud.sun.rain.fill"
        }
    }
}
