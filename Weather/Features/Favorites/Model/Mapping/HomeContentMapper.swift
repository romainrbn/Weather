//
//  HomeContentMapper.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

/// Creates the content to display on the home view, from the current state of the presenter.
struct HomeContentMapper {
    static func map(_ state: HomePresenter.State) -> HomeContent {
        let sections = [
            buildFavoritesSection(from: state.favoritesDTOs)
        ]
        .compactMap { $0 }

        return HomeContent(sections: sections)
    }

    private static func buildFavoritesSection(from items: [FavouriteItemDTO]) -> HomeSection? {
        guard !items.isEmpty else {
            return nil
        }
        
        let items = items.map { favouriteItem in
            FavouriteViewDescriptor(
                identifier: favouriteItem.identifier,
                locationName: favouriteItem.locationName ?? "-",
                isCurrentLocation: false,
                localFormattedTime: "Midnight",
                currentWeather: favouriteItem.currentTemperature?.formatted() ?? "-"
            )
        }

        return HomeSection.favourites(items)
    }
}
