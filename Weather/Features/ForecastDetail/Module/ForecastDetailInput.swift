//
//  ForecastDetailInput.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

/// Since we might have already loaded some data on the favourites view,
/// this might be a good opportunity to display the DTO properties immediately to the user, before loading the forecast endpoint.
struct ForecastDetailInput {
    let associatedItem: FavouriteItemDTO

    init(associatedItem: FavouriteItemDTO) {
        self.associatedItem = associatedItem
    }
}
