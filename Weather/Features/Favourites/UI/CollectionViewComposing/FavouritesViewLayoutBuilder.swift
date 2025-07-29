//
//  FavouritesViewLayoutBuilder.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

private enum Constants {
    static let estimatedHeaderHeight: CGFloat = 75.0
}

struct FavouritesViewLayoutBuilder {
    enum SupplementaryElementKind {
        static let headerElementKind = TitleSupplementaryView.reuseIdentifier
    }

    static func favouritesLayoutSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.headerMode = .supplementary
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .systemGroupedBackground

        let section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)
        section.contentInsets = NSDirectionalEdgeInsets(allEdges: .spacing400)
        section.interGroupSpacing = .spacing400

        let sectionHeader = headerSupplementaryView()
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
}
