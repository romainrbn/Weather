//
//  HomeSection.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum HomeSection: Hashable {
    case favourites(_ items: [HomeItem])
    case recentlyVisited(_ items: [HomeItem])

    var items: [HomeItem] {
        switch self {
        case .favourites(let items):
            return items
        case .recentlyVisited(let items):
            return items
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: HomeSection, rhs: HomeSection) -> Bool {
        switch (lhs, rhs) {
        case (.favourites, .favourites):
            return true
        case (.recentlyVisited, .recentlyVisited):
            return true
        default:
            return false
        }
    }

}

extension HomeSection {
    var title: String {
        switch self {
        case .favourites:
            return "Favourites"
        case .recentlyVisited:
            return "Recently Visited"
        }
    }
}
