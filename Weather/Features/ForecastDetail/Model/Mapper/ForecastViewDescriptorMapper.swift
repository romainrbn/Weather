//
//  ForecastViewDescriptorMapper.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation

struct ForecastViewDescriptorMapper {

    private let preferencesRepository: UserPreferencesRepository

    init(preferencesRepository: UserPreferencesRepository) {
        self.preferencesRepository = preferencesRepository
    }

    func map(
        from dto: ForecastDTO,
        timezone: TimeZone
    ) -> ForecastViewDescriptor {
        let currentDaily = mapCurrentDailyForecast(
            from: dto,
            timezone: timezone
        )

        let futureDaily = dto.nextDaysDetailedConditions.map {
            mapDailyForecast(from: $0, timezone: timezone)
        }

        return ForecastViewDescriptor(
            cityName: dto.cityName,
            currentConditions: currentDaily,
            dailyForecast: futureDaily
        )
    }

    // MARK: - Daily Forecast

    private func mapCurrentDailyForecast(from dto: ForecastDTO, timezone: TimeZone) -> ForecastViewDescriptor.DailyForecastDescriptor {
        let currentTimeFormatted = formattedTime(from: Date(), in: timezone)

        return ForecastViewDescriptor.DailyForecastDescriptor(
            associatedTime: currentTimeFormatted,
            temperature: formattedTemperature(value: dto.currentWeather.celsiusTemperature),
            minimumTemperature: formattedOptionalTemperature(value: dto.currentWeather.temperatureRanges?.minimumCelsiusTemperature),
            maximumTemperature: formattedOptionalTemperature(value: dto.currentWeather.temperatureRanges?.maximumCelsiusTemperature),
            symbol: mapSymbolDescriptor(from: dto.currentWeather),
            hourlyForecast: dto.hourlyDetailedConditions.map {
                mapHourlyForecast(from: $0, timezone: timezone)
            }
        )
    }

    private func mapDailyForecast(from daily: DailyForecast, timezone: TimeZone) -> ForecastViewDescriptor.DailyForecastDescriptor {
        ForecastViewDescriptor.DailyForecastDescriptor(
            associatedTime: formattedDay(from: daily.date, in: timezone),
            temperature: formattedTemperature(value: daily.report.celsiusTemperature),
            minimumTemperature: formattedOptionalTemperature(value: daily.report.temperatureRanges?.minimumCelsiusTemperature),
            maximumTemperature: formattedOptionalTemperature(value: daily.report.temperatureRanges?.maximumCelsiusTemperature),
            symbol: mapSymbolDescriptor(from: daily.report),
            hourlyForecast: []
        )
    }

    // MARK: - Hourly Forecast

    private func mapHourlyForecast(from hourly: HourlyForecast, timezone: TimeZone) -> ForecastViewDescriptor.HourlyForecastDescriptor {
        ForecastViewDescriptor.HourlyForecastDescriptor(
            associatedTime: formattedTime(from: hourly.time, in: timezone),
            temperature: formattedTemperature(value: hourly.report.celsiusTemperature),
            feelsLikeTemperature: formattedFeelsLikeTemperature(from: hourly.report),
            symbol: mapSymbolDescriptor(from: hourly.report)
        )
    }

    // MARK: - Symbol

    private func mapSymbolDescriptor(from report: WeatherReport) -> ForecastViewDescriptor.SymbolDescriptor {
        ForecastViewDescriptor.SymbolDescriptor(
            systemSymbolName: report.condition.associatedSystemSymbolName,
            colorRepresentation: .init(
                primaryColor: report.condition.primaryColor,
                secondaryColor: report.condition.secondaryColor,
                teriaryColor: report.condition.teriaryColor
            )
        )
    }

    // MARK: - Formatters

    private func formattedTime(from date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.timeZone = timeZone
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: date)
    }

    private func formattedDay(from date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.timeZone = timeZone
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: date)
    }

    private func formattedTemperature(value: Int) -> String {
        UserPreferredUnitConverter().formatValue(
            celsiusTemperatureValue: Double(value),
            unit: preferencesRepository.preferredTemperatureUnit
        )
    }

    private func formattedOptionalTemperature(value: Int?) -> String? {
        guard let value else { return nil }
        return formattedTemperature(value: value)
    }

    private func formattedFeelsLikeTemperature(from report: WeatherReport) -> String? {
        guard let feelsLikeTemperature = report.feelsLikeTemperature else {
            return nil
        }
        return formattedTemperature(value: feelsLikeTemperature)
    }
}
