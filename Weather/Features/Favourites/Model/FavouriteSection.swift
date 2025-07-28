//
//  FavouriteSection.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum FavouriteSection: Hashable {
    case favourites

    var title: String {
        switch self {
        case .favourites:
            return "Favourites"
        }
    }
}
