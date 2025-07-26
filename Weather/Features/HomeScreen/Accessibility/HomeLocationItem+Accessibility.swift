//
//  HomeLocationItem+Accessibility.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

extension HomeLocationItem {
    var accessibilityLabel: String {
        "The current weather is \(currentWeather)"
    }
}
