//
//  HomeViewLayoutFactory.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

private enum Constants {
    static let horizontalPadding: CGFloat = 16.0

    static let estimatedFavoriteItemHeight: CGFloat = 100.0
    static let spacingBetweenVerticalItems: CGFloat = 12.0

    static let estimatedHeaderHeight: CGFloat = 75.0
}

struct HomeViewLayoutFactory {
    enum SupplementaryElementKind {
        static let headerElementKind = TitleSupplementaryView.reuseIdentifier
    }

    /// The layout for the "Favorites" section in the home view.
    static func favoritesLayoutSection() -> NSCollectionLayoutSection {
        let group = createVerticalGroup(
            itemSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(Constants.estimatedFavoriteItemHeight)
            )
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: Constants.horizontalPadding, bottom: 0, trailing: Constants.horizontalPadding)
        section.interGroupSpacing = Constants.spacingBetweenVerticalItems

        let sectionHeader = headerSupplementaryView()
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    // MARK: - Private

    /// Generates a header for any section type.
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
