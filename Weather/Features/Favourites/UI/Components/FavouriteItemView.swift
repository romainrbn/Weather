//
//  FavouriteItemView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

private enum Constants {
    static let currentConditionsSymbolFrame: CGFloat = 48
}

struct FavouriteItemView: View {

    private let item: FavouriteViewDescriptor

    init(item: FavouriteViewDescriptor) {
        self.item = item
    }

    var body: some View {
        HStack(alignment: .center, spacing: .spacing200) {
            conditionsSymbolView

            locationTitleView

            Spacer()

            currentConditionsView
        }
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Tap to view detailed weather information")
    }

    private var conditionsSymbolView: some View {
        Image(systemName: item.currentConditionsSymbolName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .symbolRenderingMode(.palette)
            .foregroundStyle(item.primaryColor, item.secondaryColor, item.teriaryColor)
            .frame(width: Constants.currentConditionsSymbolFrame, height: Constants.currentConditionsSymbolFrame)
    }

    private var locationTitleView: some View {
        VStack(alignment: .leading) {
            Text(item.locationName)
                .font(.title3.bold())

            Text(item.localFormattedTime)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var currentConditionsView: some View {
        VStack(alignment: .center, spacing: .spacing200) {
            Text(item.currentWeather)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))

            HStack(spacing: .spacing200) {
                HStack(spacing: .spacing50) {
                    Image(systemName: "arrow.down")
                    Text(item.minimumTemperature)
                }

                Divider()

                HStack(spacing: .spacing50) {
                    Image(systemName: "arrow.up")
                    Text(item.maximumTemperature)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
