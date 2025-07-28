//
//  FavouritesViewContract.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit

/// Serves a clean interface from the presenter to the view controller.
protocol FavouritesViewContract: UIViewController {
    @MainActor func display(_ content: FavouritesViewContent)
    @MainActor func displayError(errorMessage: String)
    func performCitySearch(_ query: String)
}
