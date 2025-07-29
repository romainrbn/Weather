//
//  FavouritesViewContent.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit

struct FavouritesViewContent: Equatable {
    let items: [FavouriteViewDescriptor]
    let formattedLastUpdate: String
    let shouldDisplayLocationButton: Bool

    var locationButtonTitle: String {
        "Show Weather for my current location"
    }

    var locationButtonImage: UIImage? {
        UIImage(systemName: "location")
    }

    static let empty = FavouritesViewContent(
        items: [],
        formattedLastUpdate: "",
        shouldDisplayLocationButton: false
    )
}
