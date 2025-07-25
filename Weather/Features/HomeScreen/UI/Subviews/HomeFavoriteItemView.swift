//
//  HomeFavoriteItemView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

struct HomeFavoriteItemView: View {

    private let item: HomeLocationItem

    init(item: HomeLocationItem) {
        self.item = item
    }

    var body: some View {
        HStack {
            Image(systemName: "star").foregroundStyle(.purple)
            VStack(alignment: .leading) {
                Text(item.locationName)
                    .font(.subheadline)
                Text(item.currentWeather)
                    .font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color.green)
    }
}
