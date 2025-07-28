//
//  ForecastDetailView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import SwiftUI

struct ForecastDetailView: View {
    @StateObject private var viewModel: ForecastDetailViewModel

    @Environment(\.dismiss) var dismiss

    init(viewModel: ForecastDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if let currentWeather = viewModel.forecast {
                Text("Current Weather is \(currentWeather.currentWeather.celsiusTemperature)°C in \(viewModel.input.associatedItem.locationName)")

                Text("lat: \(viewModel.input.associatedItem.latitude), lon: \(viewModel.input.associatedItem.longitude)")
            }

            Button("Add to Favourites") {
                viewModel.addToFavourites()
                dismiss()
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
