//
//  LoadedForecastView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import SwiftUI

private enum Constants {
    static let currentTemperatureFontSize: CGFloat = 40
    static let dividerHeight: CGFloat = 80

    static let currentConditionImageSize: CGFloat = 120
    static let hourlyForecastConditionImageSize: CGFloat = 40
    static let dailyForecastConditionImageSize: CGFloat = 40
}

private struct HourlyForecastGroup: Identifiable {
    let id: Date
    let label: String
    let accessibilityTitle: String
    let entries: [ForecastViewDescriptor.HourlyForecastDescriptor]
}

struct LoadedForecastView: View {
    @EnvironmentObject private var viewModel: ForecastDetailViewModel
    private let forecast: ForecastViewDescriptor

    private let generator = UISelectionFeedbackGenerator()

    @State private var scrollTargetDate: Date?

    private var groupedHourlyForecasts: [HourlyForecastGroup] {
        let calendar = Calendar(identifier: .gregorian)

        return forecast.hourlyForecastByDay
            .compactMap { components, entries in
                guard let date = calendar.date(from: components) else { return nil }
                
                let label = formattedDay(date)
                return HourlyForecastGroup(
                    id: date,
                    label: label,
                    accessibilityTitle: date.formatted(date: .omitted, time: .shortened),
                    entries: entries.sorted(by: { $0.date < $1.date })
                )
            }
            .sorted(by: { $0.id < $1.id })
    }

    init(forecast: ForecastViewDescriptor) {
        self.forecast = forecast
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: .spacing400) {
                titleView
                currentConditionsView
                hourForecastCarouselView
                    .padding(.vertical, .spacing200)
                dayForecastCarouselView
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

            Text(forecast.currentConditions.associatedTime)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Current Conditions

    @ViewBuilder
    private var currentConditionsView: some View {
        VStack(alignment: .center, spacing: .spacing300) {
            Text(forecast.currentConditions.temperature)
                .font(.system(size: Constants.currentTemperatureFontSize, weight: .bold, design: .rounded))

            if let formattedFeelsLikeTemperature = forecast.currentConditions.feelsLikeTemperature {
                Text("Feels like: \(formattedFeelsLikeTemperature)")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            symbolView(forecast.currentConditions.symbol, size: Constants.currentConditionImageSize)

            Text(forecast.currentConditions.conditions)
                .font(.headline)
                .fontWeight(.medium)

            if let minimumTemperature = forecast.currentConditions.minimumTemperature,
               let maximumTemperature = forecast.currentConditions.maximumTemperature
            {
                TemperatureRangeView(minimumTemperature: minimumTemperature, maximumTemperature: maximumTemperature)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(forecast.currentConditions.conditions)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var hourForecastCarouselView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: .spacing200) {
                    ForEach(groupedHourlyForecasts) { group in
                        VStack(spacing: .spacing100) {
                            Text(group.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, .spacing100)

                            Divider()
                                .frame(width: 1, height: Constants.dividerHeight)
                                .background(Color.secondary)
                        }
                        .accessibilityLabel(group.accessibilityTitle)
                        .tag(group.id)

                        ForEach(group.entries, id: \.id) { hourlyForecast in
                            VStack(spacing: .spacing100) {
                                Text(hourlyForecast.formattedTime)
                                symbolView(hourlyForecast.symbol, size: Constants.hourlyForecastConditionImageSize)
                                Text(hourlyForecast.temperature)
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(hourlyForecast.temperature)
                            .padding(.horizontal, .spacing200)
                        }
                    }
                }
            }
            .onChange(of: scrollTargetDate) { newTarget in
                if let newTarget {
                    withAnimation {
                        proxy.scrollTo(newTarget, anchor: .leading)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var dayForecastCarouselView: some View {
        VStack(alignment: .leading) {
            Text("Tap a day to see its forecast")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: .spacing300) {
                    ForEach(forecast.dailyForecast) { dailyForecast in
                        Button {
                            if let matchingGroup = groupedHourlyForecasts.first(where: { $0.label == dailyForecast.associatedTime }) {
                                generator.selectionChanged()

                                scrollTargetDate = matchingGroup.id
                            }
                        } label: {
                            VStack(alignment: .center, spacing: .spacing100) {
                                Text(dailyForecast.associatedTime)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text(dailyForecast.temperature)
                                    .font(.title)
                                    .bold()

                                symbolView(dailyForecast.symbol, size: Constants.dailyForecastConditionImageSize)

                                if let minimumTemperature = dailyForecast.minimumTemperature,
                                   let maximumTemperature = dailyForecast.maximumTemperature
                                {
                                    TemperatureRangeView(
                                        minimumTemperature: minimumTemperature,
                                        maximumTemperature: maximumTemperature
                                    )
                                    .padding(.vertical, .spacing200)
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .tertiarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func symbolView(_ symbolDescription: ForecastViewDescriptor.SymbolDescriptor, size: CGFloat) -> some View {
        Image(systemName: symbolDescription.systemSymbolName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(
                symbolDescription.colorRepresentation.primaryColor,
                symbolDescription.colorRepresentation.secondaryColor,
                symbolDescription.colorRepresentation.tertiaryColor
            )
            .frame(width: size, height: size)
    }

    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: date)
    }
}
