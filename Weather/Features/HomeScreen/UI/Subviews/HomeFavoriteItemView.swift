//
//  HomeFavoriteItemView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

private enum Constants {
    static let currentConditionsSymbolFrame: CGFloat = 48
}

struct HomeFavoriteItemView: View {

    private let item: HomeLocationItem

    init(item: HomeLocationItem) {
        self.item = item
    }

    var body: some View {
        HStack {
            conditionsSymbolView

            locationTitleView

            Spacer()

            currentConditionsView
        }
    }

    private var conditionsSymbolView: some View {
        Image(systemName: "cloud.sun.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .symbolRenderingMode(.palette)
            .foregroundStyle(Color.gray.gradient, Color.yellow)
            .frame(width: Constants.currentConditionsSymbolFrame, height: Constants.currentConditionsSymbolFrame)
    }

    private var locationTitleView: some View {
        VStack(alignment: .leading) {
            Text(item.locationName)
                .font(.title3.bold())

            Text("09:41 AM")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var currentConditionsView: some View {
        VStack(alignment: .center, spacing: .spacing200) {
            Text("11°")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))

            Text(item.currentWeather)
                .font(.caption)
        }
    }
}
