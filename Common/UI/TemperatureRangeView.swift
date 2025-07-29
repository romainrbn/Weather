//
//  TemperatureRangeView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import SwiftUI

struct TemperatureRangeView: View {
    private let minimumTemperature: String
    private let maximumTemperature: String

    init(minimumTemperature: String, maximumTemperature: String) {
        self.minimumTemperature = minimumTemperature
        self.maximumTemperature = maximumTemperature
    }

    var body: some View {
        HStack(spacing: .spacing200) {
            HStack(spacing: .spacing50) {
                Image(systemName: "arrow.down")
                Text(minimumTemperature)
            }

            Divider()

            HStack(spacing: .spacing50) {
                Image(systemName: "arrow.up")
                Text(maximumTemperature)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
