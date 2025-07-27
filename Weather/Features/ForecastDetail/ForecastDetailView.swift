//
//  ForecastDetailView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import SwiftUI

struct ForecastDetailView: View {
    @StateObject private var viewModel: ForecastDetailViewModel

    init(viewModel: ForecastDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text("Hello, World!")
    }
}
