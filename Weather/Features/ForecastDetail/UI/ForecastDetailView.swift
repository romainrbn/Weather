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
        NavigationStack {
            Group {
                switch viewModel.forecast {
                case .value(let forecast):
                    loadedForecastView(forecast)
                case .loading:
                    ProgressView()
                        .progressViewStyle(.circular)
                case .error(let error):
                    errorView(error)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.toggleFavourite()
                        dismiss()
                    } label: {
                        viewModel.isFavourite ? Label("Remove from favourites", systemImage: "star.fill") : Label("Add to favourites", systemImage: "star")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }

    @ViewBuilder
    private func loadedForecastView(_ forecast: ForecastViewDescriptor) -> some View {
        LoadedForecastView(forecast: forecast)
            .environmentObject(viewModel)
    }

    @ViewBuilder
    private func errorView(_ error: any Error) -> some View {
        VStack(spacing: .spacing200) {
            Image(systemName: "xmark")
                .foregroundStyle(.accent)

            Text("Error")
                .font(.title)

            Text(error.message)
        }
    }
}
