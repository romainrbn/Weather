//
//  FavouriteItemDTO.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct FavouriteItemDTO: Equatable {
    let identifier: UUID
    let latitude: Double
    let longitude: Double
    let timezone: TimeZone
}
