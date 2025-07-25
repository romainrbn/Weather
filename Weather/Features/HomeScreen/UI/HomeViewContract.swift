//
//  HomeViewContract.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit

/// Serves a clean interface from the presenter to the view controller.
@MainActor
protocol HomeViewContract: UIViewController {
    func display(_ content: HomeContent)
}
