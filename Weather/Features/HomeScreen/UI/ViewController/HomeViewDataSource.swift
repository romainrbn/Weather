//
//  HomeViewDataSource.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit
import TipKit
import SwiftUI

/// This code could be integrated directly into `HomeViewController`.
/// It helps us split the code between pure UI and cell dequeuing logic, which can easily become verbose.
@MainActor
final class HomeViewDataSource {
    typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>

    var content: HomeContent = .empty {
        didSet {
            guard content != oldValue else { return }
            dataSource.apply(currentSnapshot)
        }
    }

    private let collectionView: UICollectionView

    private var currentSnapshot: DataSourceSnapshot {
        var snapshot = DataSourceSnapshot()
        snapshot.appendSections(content.sections)
        content.sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        
        return snapshot
    }

    private lazy var dataSource = createDataSource(for: collectionView)

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }

    private func createDataSource(
        for collectionView: UICollectionView
    ) -> HomeDataSource {
        let favouriteRegistration = favouriteCellRegistration()
        let headerRegistration = headerRegistration()

        let dataSource = HomeDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .location(let locationItem):
                return collectionView.dequeueConfiguredReusableCell(
                    using: favouriteRegistration,
                    for: indexPath,
                    item: locationItem
                )
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case HomeViewLayoutFactory.SupplementaryElementKind.headerElementKind, UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                assert(false, "This supplementary is not handled. Please handle it.")
                return nil
            }
        }

        return dataSource
    }
}

// MARK: - Registrations

extension HomeViewDataSource {
    private func favouriteCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, HomeLocationItem> {
        return UICollectionView.CellRegistration<UICollectionViewCell, HomeLocationItem> { (cell, _, item) in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                HomeFavoriteItemView(item: item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {} label: {
                            Label("Pin", systemImage: "mappin.circle")
                        }
                        .tint(.blue)
                    }
                    .listRowInsets(
                        EdgeInsets(
                            NSDirectionalEdgeInsets(vertical: .spacing400)
                        )
                    )
            })
            cell.backgroundColor = .secondarySystemGroupedBackground
            cell.layer.cornerRadius = .spacing300
        }
    }

    private func headerRegistration() -> UICollectionView.SupplementaryRegistration<TitleSupplementaryView> {
        return UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: HomeViewLayoutFactory.SupplementaryElementKind.headerElementKind
        ) { [weak self] (cell, _, indexPath) in
            guard
                let self,
                let section = dataSource.sectionIdentifier(for: indexPath.section)
            else { return }
            cell.content = .init(title: section.title)
        }
    }
}
