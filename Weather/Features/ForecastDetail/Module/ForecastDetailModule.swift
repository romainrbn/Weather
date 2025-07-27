//
//  ForecastDetailModule.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import SwiftUI
import UIKit

struct ForecastDetailModule {
    private(set) var viewController: UIHostingController<ForecastDetailView>
    private var viewModel: ForecastDetailViewModel

    init(input: ForecastDetailInput, dependencies: ForecastDetailDependencies) {
        self.viewModel = ForecastDetailViewModel(input: input, dependencies: dependencies)
        self.viewController = UIHostingController(
            rootView: ForecastDetailView(viewModel: viewModel)
        )
    }
}
