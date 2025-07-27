//
//  FavouriteViewDescriptor.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct FavouriteViewDescriptor: Hashable {
    let identifier: UUID
    let locationName: String
    let isCurrentLocation: Bool
    let localFormattedTime: String
    let currentWeather: String
}
