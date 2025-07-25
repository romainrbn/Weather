//
//  HomeModule.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

/// A single creation point for the Home feature.
///
/// In a more complex app, this module (and the dependencies) would be the only objects exposed publicly,
/// letting the view controller and presenter internal to the feature's module.
struct HomeModule {
    private(set) var viewController: HomeViewController
    private var presenter: HomePresenter

    init(dependencies: HomePresenter.Dependencies) {
        viewController = HomeViewController()
        presenter = HomePresenter(
            dependencies: dependencies,
            viewContract: viewController
        )
        viewController.presenter = presenter
    }
}
