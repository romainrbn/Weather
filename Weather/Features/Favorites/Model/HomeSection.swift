//
//  HomeSection.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum HomeSection: Hashable {
    case favourites(_ items: [FavouriteViewDescriptor])

    var items: [FavouriteViewDescriptor] {
        switch self {
        case .favourites(let items):
            return items
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: HomeSection, rhs: HomeSection) -> Bool {
        lhs.title == rhs.title && lhs.items == rhs.items
    }
}

extension HomeSection {
    var title: String {
        switch self {
        case .favourites:
            return "Favourites"
        }
    }
}
