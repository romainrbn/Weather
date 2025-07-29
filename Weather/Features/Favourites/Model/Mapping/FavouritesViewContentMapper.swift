//
//  FavouritesViewContentMapper.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

/// Creates the content to display on the favourites view, from the current state of the presenter.
struct FavouritesViewContentMapper {

    private let preferencesRepository: UserPreferencesRepository

    init(preferencesRepository: UserPreferencesRepository) {
        self.preferencesRepository = preferencesRepository
    }

    func map(
        _ state: FavouritesPresenter.State
    ) -> FavouritesViewContent {
        FavouritesViewContent(
            items: buildFavouriteItems(from: state.favouriteDTOs)
        )
    }

    private func buildFavouriteItems(from items: [FavouriteItemDTO]) -> [FavouriteViewDescriptor] {
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

    private func favouriteViewDescriptor(from favouriteItem: FavouriteItemDTO) -> FavouriteViewDescriptor? {
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
            formattedCurrentTemperature: formattedTemperature(value: currentWeather.celsiusTemperature),
            formattedCurrentConditions: currentWeather.conditionName.capitalized,
            currentConditionsSymbolName: currentWeather.condition.associatedSystemSymbolName,
            minimumTemperature: formattedTemperature(value: temperatureRange.minimumCelsiusTemperature),
            maximumTemperature: formattedTemperature(value: temperatureRange.maximumCelsiusTemperature),
            primaryColor: currentWeather.condition.primaryColor,
            secondaryColor: currentWeather.condition.secondaryColor,
            teriaryColor: currentWeather.condition.teriaryColor
        )
    }

    private func formattedCurrentTime(in timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = .autoupdatingCurrent

        return dateFormatter.string(from: Date())
    }

    private func formattedTemperature(value: Int) -> String {
        UserPreferredUnitConverter().formatValue(
            celsiusTemperatureValue: Double(value),
            unit: preferencesRepository.preferredTemperatureUnit
        )
    }
}

extension WeatherCondition {
    // Allows us to switch only once on all conditions
    private struct Model {
        let associatedSystemSymbolName: String
        let primaryColor: Color
        let secondaryColor: Color?
        let teriaryColor: Color?

        init(
            associatedSystemSymbolName: String,
            primaryColor: Color,
            secondaryColor: Color? = nil,
            teriaryColor: Color? = nil
        ) {
            self.associatedSystemSymbolName = associatedSystemSymbolName
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
            self.teriaryColor = teriaryColor
        }
    }

    private var model: Model {
        switch self {
        case .clear:
            Model(associatedSystemSymbolName: "sun.max.fill", primaryColor: .yellow)
        case .clouds:
            Model(associatedSystemSymbolName: "cloud.fill", primaryColor: .gray)
        case .thunderstorm:
            Model(associatedSystemSymbolName: "cloud.bolt.fill", primaryColor: .gray, secondaryColor: .yellow)
        case .drizzle:
            Model(associatedSystemSymbolName: "cloud.drizzle.fill", primaryColor: .gray, secondaryColor: .blue)
        case .rain:
            Model(associatedSystemSymbolName: "cloud.rain.fill", primaryColor: .gray, secondaryColor: .blue)
        case .snow:
            Model(associatedSystemSymbolName: "cloud.snow.fill", primaryColor: .gray, secondaryColor: .blue)
        case .atmosphere:
            Model(associatedSystemSymbolName: "sun.dust.fill", primaryColor: .orange, secondaryColor: .yellow) // TODO: map more
        case .unknown:
            Model(associatedSystemSymbolName: "cloud.sun.rain.fill", primaryColor: .gray, secondaryColor: .yellow, teriaryColor: .blue)
        }
    }

    var associatedSystemSymbolName: String {
        model.associatedSystemSymbolName
    }

    var primaryColor: Color {
        model.primaryColor
    }

    var secondaryColor: Color {
        model.secondaryColor ?? model.primaryColor
    }

    var teriaryColor: Color {
        model.teriaryColor ?? secondaryColor
    }
}
