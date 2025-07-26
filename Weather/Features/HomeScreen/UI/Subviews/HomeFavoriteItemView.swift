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
            Image(systemName: "cloud.sun.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.gray.gradient, Color.yellow)
                .frame(width: Constants.currentConditionsSymbolFrame, height: Constants.currentConditionsSymbolFrame)

            VStack(alignment: .leading) {
                Text(item.locationName)
                    .font(.title3.bold())

                Text(item.currentWeather)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
