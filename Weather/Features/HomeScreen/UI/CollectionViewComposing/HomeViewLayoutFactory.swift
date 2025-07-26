//
//  HomeViewLayoutFactory.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

private enum Constants {
    static let padding: CGFloat = 16.0

    static let estimatedFavoriteItemHeight: CGFloat = 100.0
    static let spacingBetweenVerticalItems: CGFloat = 12.0

    static let estimatedHeaderHeight: CGFloat = 75.0
}

struct HomeViewLayoutFactory {
    enum SupplementaryElementKind {
        static let headerElementKind = TitleSupplementaryView.reuseIdentifier
    }

    /// The layout for the "Favorites" section in the home view.
    static func favoritesLayoutSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.headerMode = .supplementary
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .systemGroupedBackground

        let section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)
        section.contentInsets = .init(allEdges: .spacing400)
        section.interGroupSpacing = .spacing400

        let sectionHeader = headerSupplementaryView()
        sectionHeader.contentInsets = .init(horizontal: .spacing400)
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    // MARK: - Private

    /// Generates a simple title header for any section type.
    private static func headerSupplementaryView() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.estimatedHeaderHeight)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: SupplementaryElementKind.headerElementKind,
            alignment: .topLeading
        )
    }

    private static func createVerticalGroup(itemSize: NSCollectionLayoutSize) -> NSCollectionLayoutGroup {
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(Constants.estimatedFavoriteItemHeight)
            ),
            subitems: [item]
        )
        group.interItemSpacing = .fixed(Constants.spacingBetweenVerticalItems)
        return group
    }
}
