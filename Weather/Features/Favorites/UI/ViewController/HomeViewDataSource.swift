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
    typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, FavouriteViewDescriptor>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<HomeSection, FavouriteViewDescriptor>

    var content: FavouritesViewContent = .empty {
        didSet {
            guard content != oldValue else { return }
            dataSource.apply(currentSnapshot)
        }
    }

    private weak var presenter: HomePresenter?
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

    init(collectionView: UICollectionView, presenter: HomePresenter?) {
        self.collectionView = collectionView
        self.presenter = presenter
    }

    private func createDataSource(
        for collectionView: UICollectionView
    ) -> HomeDataSource {
        let favouriteRegistration = favouriteCellRegistration()
        let headerRegistration = headerRegistration()

        let dataSource = HomeDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(
                using: favouriteRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case HomeViewLayoutBuilder.SupplementaryElementKind.headerElementKind, UICollectionView.elementKindSectionHeader:
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
    private func favouriteCellRegistration() -> UICollectionView.CellRegistration<
        UICollectionViewCell, FavouriteViewDescriptor
    > {
        return UICollectionView.CellRegistration<UICollectionViewCell, FavouriteViewDescriptor> { (cell, _, item) in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                HomeFavoriteItemView(item: item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        HomeFavoriteItemSwipeActionsView(onRemoveFavorite: { [weak self] in
                            self?.presenter?.removeFavorite(item)
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
            elementKind: HomeViewLayoutBuilder.SupplementaryElementKind.headerElementKind
        ) { [weak self] (cell, _, indexPath) in
            guard
                let self,
                let section = dataSource.sectionIdentifier(for: indexPath.section)
            else { return }
            cell.content = .init(title: section.title)
        }
    }
}
