//
//  FavouriteItemView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

private enum Constants {
    static let currentConditionsSymbolFrame: CGFloat = 48
    static let temperatureLabelMinimumScaleFactor: CGFloat = 0.8
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
            .foregroundStyle(
                item.conditionSymbolColorRepresentation.primaryColor,
                item.conditionSymbolColorRepresentation.secondaryColor,
                item.conditionSymbolColorRepresentation.tertiaryColor
            )
            .frame(width: Constants.currentConditionsSymbolFrame, height: Constants.currentConditionsSymbolFrame)
    }

    private var locationTitleView: some View {
        VStack(alignment: .leading) {
            Group {
                if item.isCurrentLocation {
                    HStack(spacing: .spacing100) {
                        Image(systemName: "location.fill")
                            .imageScale(.small)
                        Text(item.locationName)
                            .font(.title3.bold())
                    }
                } else {
                    Text(item.locationName)
                        .font(.title3.bold())
                }
            }
            .foregroundStyle(.primary)

            Text(item.localFormattedTime)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var currentConditionsView: some View {
        VStack(alignment: .center, spacing: .spacing200) {
            Text(item.formattedCurrentTemperature)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .minimumScaleFactor(Constants.temperatureLabelMinimumScaleFactor)

            Text(item.formattedCurrentConditions)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.secondary)
                .padding(.bottom)
                .fixedSize(horizontal: false, vertical: true)

            TemperatureRangeView(minimumTemperature: item.minimumTemperature, maximumTemperature: item.maximumTemperature)
        }
    }
}
