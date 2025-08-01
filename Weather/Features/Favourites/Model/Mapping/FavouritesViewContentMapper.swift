//
//  FavouritesViewContentMapper.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

private enum Constants {
    static let secondsInAMinute: TimeInterval = 60
}

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
            items: buildFavouriteItems(from: state.favouriteDTOs),
            formattedLastUpdate: Self.formatLastUpdateDate(state.lastUpdate),
            shouldDisplayLocationButton: state.shouldDisplayLocationButton
        )
    }

    static func formatLastUpdateDate(_ date: Date) -> String {
        let timeDifference = Date.now.timeIntervalSince(date)
        let prefix: String = "Last update:"
        if timeDifference < 5 {
            return "\(prefix) Now"
        }

        if timeDifference < Constants.secondsInAMinute {
            return "\(prefix) A few moments ago"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let localizedFormattedString = formatter.localizedString(for: date, relativeTo: Date.now)

        return "\(prefix) \(localizedFormattedString)"
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
            let temperatureRange = currentWeather.temperatureRanges
        else {
            return nil
        }

        return FavouriteViewDescriptor(
            identifier: favouriteItem.identifier,
            locationName: favouriteItem.locationName,
            isCurrentLocation: favouriteItem.isCurrentLocation,
            localFormattedTime: formattedCurrentTime(in: favouriteItem.timezone),
            formattedCurrentTemperature: formattedTemperature(value: currentWeather.celsiusTemperature),
            formattedCurrentConditions: currentWeather.conditionName.capitalized,
            currentConditionsSymbolName: currentWeather.condition.associatedSystemSymbolName,
            minimumTemperature: formattedTemperature(value: temperatureRange.minimumCelsiusTemperature),
            maximumTemperature: formattedTemperature(value: temperatureRange.maximumCelsiusTemperature),
            conditionSymbolColorRepresentation: .init(
                primaryColor: currentWeather.condition.primaryColor,
                secondaryColor: currentWeather.condition.secondaryColor,
                tertiaryColor: currentWeather.condition.tertiaryColor
            )
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
        let tertiaryColor: Color?

        init(
            associatedSystemSymbolName: String,
            primaryColor: Color,
            secondaryColor: Color? = nil,
            tertiaryColor: Color? = nil
        ) {
            self.associatedSystemSymbolName = associatedSystemSymbolName
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
            self.tertiaryColor = tertiaryColor
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
            Model(associatedSystemSymbolName: "sun.dust.fill", primaryColor: .orange, secondaryColor: .yellow)
        case .unknown:
            Model(associatedSystemSymbolName: "cloud.sun.rain.fill", primaryColor: .gray, secondaryColor: .yellow, tertiaryColor: .blue)
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

    var tertiaryColor: Color {
        model.tertiaryColor ?? secondaryColor
    }
}
