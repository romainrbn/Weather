//
//  HomeViewContract.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit

/// Serves a clean interface from the presenter to the view controller.
protocol HomeViewContract: UIViewController {
    @MainActor func display(_ content: HomeContent)
    func performCitySearch(_ query: String)
}
