//
//  HomeEmptyView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI
import CoreLocation

private enum Constants {
    static let symbolSize: CGFloat = 50
}

/// Mimics a `ContentUnavailableView`, but for iOS 16+
struct HomeEmptyView: View {

    private let onUseCurrentLocationTapped: (() -> Void)?

    init(onUseCurrentLocationTapped: (() -> Void)?) {
        self.onUseCurrentLocationTapped = onUseCurrentLocationTapped
    }

    var body: some View {
        VStack(alignment: .center, spacing: .spacing200) {
            Image(systemName: "bookmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.cyan)
                .frame(width: Constants.symbolSize, height: Constants.symbolSize)

            Text("No Favourites")
                .font(.title)
                .bold()

            VStack(spacing: .spacing100) {
                Text("Add favourites by searching a city in the field above.")

                if CLLocationManager().authorizationStatus == .notDetermined {
                    Text("- or -")
                        .foregroundStyle(.tertiary)
                        .font(.caption2)

                    Button(action: {
                        onUseCurrentLocationTapped?()
                    }) {
                        Label("Use my current location", systemImage: "location")
                    }
                    .foregroundStyle(.cyan)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}
