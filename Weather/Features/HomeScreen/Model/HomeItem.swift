//
//  HomeItem.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum HomeItem: Hashable {
    case location(HomeLocationItem)
}

struct HomeLocationItem: Hashable {
    let locationName: String
    let currentWeather: String
}
