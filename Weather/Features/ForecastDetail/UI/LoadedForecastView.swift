//
//  LoadedForecastView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import SwiftUI

struct LoadedForecastView: View {
    @EnvironmentObject private var viewModel: ForecastDetailViewModel
    private let forecast: ForecastViewDescriptor

    init(forecast: ForecastViewDescriptor) {
        self.forecast = forecast
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: .spacing300) {
                titleView
            }
            .padding(.spacing400)
        }
    }

    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: .spacing100) {
            Text(forecast.cityName)
                .font(.largeTitle)
                .bold()

            Text("Now")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
