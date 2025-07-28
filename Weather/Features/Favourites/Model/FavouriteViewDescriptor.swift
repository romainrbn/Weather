//
//  FavouriteViewDescriptor.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

struct FavouriteViewDescriptor: Hashable {
    let identifier: String
    let locationName: String
    let isCurrentLocation: Bool
    let localFormattedTime: String
    let currentWeather: String
    let currentConditionsSymbolName: String
    let minimumTemperature: String
    let maximumTemperature: String
    let primaryColor: Color
    let secondaryColor: Color
    let teriaryColor: Color

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: FavouriteViewDescriptor, rhs: FavouriteViewDescriptor) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
