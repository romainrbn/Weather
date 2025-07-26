//
//  HomeContent.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct HomeContent: Equatable {
    let sections: [HomeSection]

    static let empty = HomeContent(sections: [])

    // Custom Equatable implementation, to help the diffable data source compute differences between sections/items.
    static func == (lhs: HomeContent, rhs: HomeContent) -> Bool {
        guard lhs.sections.count == rhs.sections.count else { return false }

        for (lhsSection, rhsSection) in zip(lhs.sections, rhs.sections) {
            switch (lhsSection, rhsSection) {
            case (.favourites(let lhsItems), .favourites(let rhsItems)):
                if lhsItems != rhsItems {
                    return false
                }
            case (.recentlyVisited(let lhsItems), .recentlyVisited(let rhsItems)):
                if lhsItems != rhsItems {
                    return false
                }
            default:
                return false
            }
        }

        return true
    }
}
