//
//  FavouritesViewDataSource.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit
import TipKit
import SwiftUI

/// This code could be integrated directly into `FavouritesViewController`.
/// It helps us split the code between pure UI and cell dequeuing logic, which can easily become verbose.
@MainActor
final class FavouritesViewDataSource {
    typealias FavouritesDataSource = UICollectionViewDiffableDataSource<FavouriteSection, FavouriteViewDescriptor>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<FavouriteSection, FavouriteViewDescriptor>

    var content: FavouritesViewContent = .empty {
        didSet {
            guard content != oldValue else { return }
            dataSource.apply(currentSnapshot)
        }
    }

    private weak var presenter: FavouritesPresenter?
    private let collectionView: UICollectionView

    private var currentSnapshot: DataSourceSnapshot {
        var snapshot = DataSourceSnapshot()

        if content.items.isEmpty == false {
            snapshot.appendSections([.favourites])
            snapshot.appendItems(content.items, toSection: .favourites)
        }
        
        return snapshot
    }

    private lazy var dataSource = createDataSource(for: collectionView)

    init(collectionView: UICollectionView, presenter: FavouritesPresenter?) {
        self.collectionView = collectionView
        self.presenter = presenter
    }

    private func createDataSource(
        for collectionView: UICollectionView
    ) -> FavouritesDataSource {
        let favouriteRegistration = favouriteCellRegistration()
        let headerRegistration = headerRegistration()

        let dataSource = FavouritesDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(
                using: favouriteRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case FavouritesViewLayoutBuilder.SupplementaryElementKind.headerElementKind, UICollectionView.elementKindSectionHeader:
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

extension FavouritesViewDataSource {
    private func favouriteCellRegistration() -> UICollectionView.CellRegistration<
        UICollectionViewCell, FavouriteViewDescriptor
    > {
        return UICollectionView.CellRegistration<UICollectionViewCell, FavouriteViewDescriptor> { (cell, _, item) in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                FavouriteItemView(item: item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        FavouriteItemSwipeActionsView(onRemoveFavourite: { [weak self] in
                            self?.presenter?.removeFavourite(item)
                        })
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
            elementKind: FavouritesViewLayoutBuilder.SupplementaryElementKind.headerElementKind
        ) { [weak self] (cell, _, indexPath) in
            guard
                let self,
                let section = dataSource.sectionIdentifier(for: indexPath.section)
            else { return }
            cell.content = .init(title: section.title)
        }
    }
}
