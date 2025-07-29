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
    let formattedCurrentTemperature: String
    let formattedCurrentConditions: String
    let currentConditionsSymbolName: String
    let minimumTemperature: String
    let maximumTemperature: String
    let conditionSymbolColorRepresentation: ConditionSymbolColorRepresentation
}
