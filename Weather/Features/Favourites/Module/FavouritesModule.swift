//
//  FavouritesModule.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit

/// A single creation point for the favourites feature.
///
/// In a more complex app, this module (and the dependencies) would be the only objects exposed publicly,
/// letting the view controller and presenter internal to the feature's module.
@MainActor
struct FavouritesModule {
    private(set) var viewController: FavouritesViewController
    private var presenter: FavouritesPresenter

    init(dependencies: FavouriteDependencies) {
        viewController = FavouritesViewController(collectionViewLayout: UICollectionViewFlowLayout())
        presenter = FavouritesPresenter(
            dependencies: dependencies,
            viewContract: viewController
        )
        viewController.presenter = presenter
    }
}
