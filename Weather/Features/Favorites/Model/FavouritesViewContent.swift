//
//  FavouritesViewContent.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct FavouritesViewContent: Equatable {
    let items: [FavouriteViewDescriptor]

    static let empty = FavouritesViewContent(items: [])
}
