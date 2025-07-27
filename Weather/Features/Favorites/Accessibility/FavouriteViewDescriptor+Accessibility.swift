//
//  FavouriteViewDescriptor+Accessibility.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

extension FavouriteViewDescriptor {
    // In a production context, we would use a LocalizedString here to provide VoiceOver content in different languages.
    var accessibilityLabel: String {
        """
        It's currently \(currentWeather). Today's high will be \(maximumTemperature) and the low will be \(minimumTemperature).
        """
    }
}
